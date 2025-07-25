# frozen_string_literal: true

module Users
  class Student < User
    include StudentAdmin
    include UserWithSchool

    BITLY_STUDENT_WELCOME_URL = 'https://bit.ly/4athP2e' # internship_offers_url in production

    belongs_to :school, optional: true
    belongs_to :class_room, optional: true
    belongs_to :grade, optional: true

    has_many :internship_applications, dependent: :destroy,
                                       foreign_key: 'user_id' do
      def weekly_framed
        where(type: InternshipApplications::WeeklyFramed.name)
      end
    end
    has_many :internship_agreements, through: :internship_applications
    has_many :internship_offers, through: :favorites

    scope :without_class_room, -> { where(class_room_id: nil, anonymized: false) }

    delegate :school_manager,
             to: :school

    validates :birth_date,
              :gender,
              :grade,
              presence: true

    validate :validate_school_presence_at_creation

    # Callbacks
    # before_save :skip_confirmation!
    after_create :clean_phone_or_email_when_empty # , :welcome_new_student :set_reminders

    def student? = true

    def channel
      return :email if email.present?

      :phone
    end

    def has_zero_internship_application?
      internship_applications.all
                             .size
                             .zero?
    end

    def age
      ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor
    end

    def to_s
      "#{super}, élève dans l'établissement #{school&.name}, #{school&.city}"
    end

    def after_sign_in_path
      if targeted_offer_id.present?
        url_helpers.internship_offer_path(id: canceled_targeted_offer_id)
      else
        presenter.default_internship_offers_path
      end
    end

    def custom_dashboard_path
      url_helpers.dashboard_students_internship_applications_path(self)
    end

    def custom_candidatures_path(parameters = {})
      custom_dashboard_path
    end

    def dashboard_name
      'Candidatures'
    end

    def default_account_section
      'resume'
    end

    def school_manager_email
      school_manager&.email
    end

    def needs_to_see_modal?
      internship_applications.validated_by_employer.any?
    end

    def seconde_gt?
      grade == Grade.seconde
    end

    def troisieme_ou_quatrieme?
      grade.in?(Grade.troisieme_et_quatrieme)
    end
    alias troisieme_or_quatrieme? troisieme_ou_quatrieme?

    def belongs_to_qpv_school? = school.qpv?
    def belongs_to_rep_school? = school.rep_kind == 'rep'
    def belongs_to_rep_plus_school? = school.rep_kind == 'rep_plus'
    def belongs_to_rep_or_rep_plus_school? = school.rep_kind&.in?(%w[rep rep_plus])

    def main_teacher
      return nil if try(:class_room).nil?

      class_room.school_managements
                &.main_teachers
                &.first
    end

    def available_offers(max_distance: Finders::ContextTypableInternshipOffer::MAX_RADIUS_SEARCH_DISTANCE)
      Finders::InternshipOfferConsumer.new(user: self, params: {})
                                      .available_offers(max_distance:)
    end

    def has_offers_to_apply_to?(max_distance: Finders::ContextTypableInternshipOffer::MAX_RADIUS_SEARCH_DISTANCE)
      available_offers(max_distance:).any?
    end

    def add_responsible_data
      responsible = Services::Omogen::Sygne.new.try(:sygne_responsable, ine)
      return self if responsible.blank?

      self.legal_representative_full_name = "#{responsible.civility} #{responsible.first_name} #{responsible.last_name}"
      self.legal_representative_email = responsible.email
      self.legal_representative_phone = responsible.phone
      save
      self
    end

    def anonymize(send_email: true)
      super(send_email:)

      update_columns(birth_date: nil,
                     current_sign_in_ip: nil,
                     last_sign_in_ip: nil,
                     class_room_id: nil,
                     resume_other: nil,
                     resume_educational_background: nil,
                     resume_languages: nil,
                     gender: nil,
                     ine: nil,
                     address: nil,
                     legal_representative_full_name: nil,
                     legal_representative_phone: nil,
                     legal_representative_email: nil)
      update_columns(phone: 'NA') unless phone.nil?
      internship_applications.map(&:anonymize)
    end

    def validate_school_presence_at_creation
      return unless new_record? && school.blank?

      errors.add(:school, :blank)
    end

    def resend_confirmation_phone_token
      return unless phone.present?

      message = "Votre code de validation : #{phone_token}"
      SendSmsJob.perform_later(user: self, message:)
    end

    def valid_transition?(transition)
      %w[ submit!
          submit
          approve!
          approve
          reject!
          reject
          restore
          restore!
          cancel_by_student!
          cancel_by_student].include?(transition)
    end

    def compute_weeks_lists
      school_weeks_list = school&.weeks.presence || Week.both_school_track_selectable_weeks
      preselected_weeks_list = school_weeks_list.in_the_future
      [school_weeks_list, preselected_weeks_list]
    end

    def presenter
      Presenters::Student.new(self)
    end

    def with_2_weeks_internships_approved?
      return false if troisieme_ou_quatrieme?
      return false if internship_applications.empty? || internship_applications.approved.empty?

      approved_offers = internship_applications.approved.map(&:internship_offer)
      return true if approved_offers.any? { |offer| offer.weeks.count == 2 }
      return true if approved_offers.map(&:weeks).uniq.count == 2

      false
    end

    def other_approved_applications_compatible?(internship_offer:)
      # one week internship only for troisieme and quatrieme
      # seconde only from now on
      return true if internship_applications.empty? || internship_applications.approved.empty?
      return false if troisieme_ou_quatrieme? && internship_applications.approved.size.positive?

      # student is seconde
      return false if with_2_weeks_internships_approved?
      return false if internship_offer.nil?

      # second student with one and only one week already approved
      approved_offers_week_ids = internship_applications.approved.map(&:weeks).flatten.map(&:id).uniq
      official_seconde_weeks_ids = SchoolTrack::Seconde.both_weeks.map(&:id)

      internship_offer_seconde_week_ids = (internship_offer.weeks.map(&:id) & official_seconde_weeks_ids)
      student_free_week_id = official_seconde_weeks_ids - approved_offers_week_ids

      student_free_week_id == internship_offer_seconde_week_ids
    end

    def has_found_her_internships?
      return true if troisieme_ou_quatrieme? && internship_applications.approved.count.positive?

      with_2_weeks_internships_approved?
    end

    def log_search_history(search_params)
      search_history = UsersSearchHistory.new(
        keywords: search_params[:keyword],
        latitude: search_params[:latitude],
        longitude: search_params[:longitude],
        city: search_params[:city],
        radius: search_params[:radius],
        results_count: search_params[:results_count]&.to_i || 0,
        user: self
      )
      search_history.save
    end

    def welcome_new_student
      return if email.blank?
      return if phone.present?

      StudentMailer.welcome_email(student: self, shrinked_url: BITLY_STUDENT_WELCOME_URL)
                   .deliver_later
    end

    def set_reminders
      SendReminderToStudentsWithoutApplicationJob.set(wait: 3.day).perform_later(id)
    end

    def clean_phone_or_email_when_empty
      update_columns(phone: nil) if phone.blank?
      update_columns(email: nil) if email.blank?
    end

    def fake_email?
      email.present? && email.split('@').last.downcase == "#{school.code_uai}.fr".downcase
    end

    rails_admin do
      weight 1

      list do
        field :ine
      end

      show do
        fields(:ine)
      end
      export do
        fields(:ine)
      end
    end
  end
end
