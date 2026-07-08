module Presenters
  class InternshipApplication
    include ::ActionView::Helpers::DateHelper
    include ::ActionView::Helpers::TagHelper
    include ::ActionView::Helpers::TextHelper
    include ::ActionView::Helpers::OutputSafetyHelper

    delegate :student, to: :internship_application
    delegate :internship_offer, to: :internship_application
    delegate :title, to: :internship_offer, prefix: true
    delegate :employer_name, to: :internship_offer
    delegate :period, to: :internship_offer
    delegate :canceled_by_employer_message, to: :internship_application
    delegate :rejected_message, to: :internship_application

    SUBMITTED_LIKE_STATES = %w[submitted
                               restored
                               read_by_employer
                               transfered].freeze

    def expires_in
      start = internship_application.updated_at
      finish = start + ::InternshipApplication::EXPIRATION_DURATION
      distance_of_time_in_words_to_now(finish, include_days: true)
    end

    def internship_offer_address
      internship_application.internship_offer
                            .presenter
                            .address
    end

    def internship_offer_title
      internship_offer.title
    end

    def human_state
      HumanState.for(application: internship_application, role: reader_role, application_path: internship_application_path).to_h
    rescue HumanState::UnknownState, HumanState::UnknownRole => e
      Sentry.capture_exception(e)
      {}
    end

    def actions_in_show_page
      return '' if internship_application.aasm_state.nil?

      student_has_found = internship_application.student
                                                .with_2_weeks_internships_approved?
      student_has_found ? actions_when_student_has_found : actions_when_student_has_not_found
    end

    def actions_when_student_has_found
      return [] unless internship_application.approved?

      [{ label: 'Contacter l\'offreur',
         color: 'primary',
         level: 'tertiary' }]
    end

    def actions_when_student_has_not_found
      case internship_application.aasm_state
      when 'submitted'
        [{ label: 'Renvoyer la demande',
           color: 'primary',
           level: 'primary' }]

      when 'transfered'
        [{ label: 'Renvoyer la demande',
           color: 'primary',
           level: 'primary' }]

      when 'read_by_employer'
        [{ label: 'Renvoyer la demande',
           color: 'primary',
           level: 'tertiary' }]

      when 'validated_by_employer'
        [{ label: 'Choisir ce stage',
           form_path: internship_application_path,
           transition: 'approve!',
           color: 'primary',
           level: 'primary' }]
      when 'approved'
        [{ label: 'Contacter l\'offreur',
           color: 'primary',
           level: 'tertiary' }]

      when 'canceled_by_employer', 'rejected', 'canceled_by_student', 'expired', 'canceled_by_student_confirmation'
        []

      else
        []
      end
    end

    def ok_for_transfer?
      return false if internship_offer.remaining_seats_count.to_i <= 0

      current_state_in_list?(ok_for_transfer_states)
    end

    def ok_for_reject?
      internship_application.rejectable?
    end

    def ok_for_employer_validation?
      current_state_in_list?(SUBMITTED_LIKE_STATES)
    end

    def with_employer_explanation?
      unless internship_application.aasm_state.in?(::InternshipApplication.with_employer_explanations_states)
        return false
      end

      explanation_count.positive?
    end

    def explanation_count
      count = 0
      count += 1 if internship_application.canceled_by_employer_message?
      count += 1 if internship_application.rejected_message?
      count
    end

    def employer_explanations
      motives = []
      canceled_motive = { meth: :canceled_by_employer_message, label: "Annulation par l'entreprise" }
      rejected_motive = { meth: :rejected_message, label: "Refus par l'entreprise" }

      motives << canceled_motive if internship_application.canceled_by_employer_message?
      motives << rejected_motive if internship_application.rejected_message?

      motives.filter_map do |motive|
        text = internship_application.public_send(motive[:meth])
        next if text.blank?

        safe_join([
          tag.strong("#{motive[:label]} :"),
          tag.br,
          simple_format(text)
        ])
      end
    end

    def str_weeks
      WeekList.new(weeks:).to_s
    end

    def date_range
      "Du #{internship_application.weeks.first.monday.strftime('%d/%m/%Y')} au #{internship_application.weeks.last.friday.strftime('%d/%m/%Y')}"
    end

    attr_reader :internship_application,
                :student,
                :internship_offer,
                :reader,
                :weeks

    protected

    def initialize(internship_application, user)
      @reader = user
      @internship_application = internship_application
      @student                = internship_application.student
      @internship_offer       = internship_application.internship_offer
      @weeks                  = internship_application.weeks
    end

    def rails_routes
      Rails.application.routes.url_helpers
    end

    def internship_application_path
      rails_routes.dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        uuid: internship_application.uuid
      )
    end

    def edit_internship_application_path
      rails_routes.edit_dashboard_students_internship_application_path(
        student_id: internship_application.user_id,
        uuid: internship_application.uuid
      )
    end

    private

    def reader_role
      if reader.student?            then :student
      elsif reader.school_management? then :school_management
      else                               :employer
      end
    end

    def current_state_in_list?(state_array)
      state_array.include?(internship_application.aasm_state)
    end

    def ok_for_transfer_states
      %w[submitted restored read_by_employer]
    end
  end
end
