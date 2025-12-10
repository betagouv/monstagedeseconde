# to switch/branch validation, we use an home made mechanism
# which requires either one of those fields:
# - enforce_employer_validation : forcing employer validations
# - enforce_school_manager_validations : forcing school_manager validations
#
# only use dedicated builder to CRUD those objects
class InternshipAgreement < ApplicationRecord
  include AASM
  include Discard::Model
  include InternshipAgreementSignaturable
  include Tokenable

  MIN_PRESENCE_DAYS = 4
  EMPLOYERS_PENDING_STATES  = %i[draft started_by_employer signed_by_employer validated].freeze
  PENDING_SIGNATURES_STATES = %i[validated signatures_started signed_by_all].freeze
  EXPECTED_ACTION_FROM_EMPLOYER_STATES = %i[draft started_by_employer completed_by_employer].freeze

  has_many :signatures, dependent: :destroy
  belongs_to :internship_application, optional: false

  after_create :generate_token, unless: :access_token?

  # beware, complementary_terms_rich_text/lega_terms_rich_text are recopy from school.internship_agreement_presets.*
  #         it must stay a recopy and not a direct link (must live separatery)

  attr_accessor :enforce_school_manager_validations,
                :enforce_employer_validations,
                :enforce_teacher_validations,
                :skip_validations_for_system,
                :skip_notifications_when_system_creation

  # Validations
  with_options if: :enforce_employer_validations? do
    validates :activity_scope, presence: true, length: { maximum: 1500 }
    validate :valid_working_hours_fields
    validate :at_least_daily_hours_or_weekly_hours
  end

  with_options if: :enforce_teacher_validations? do
    validates :student_class_room, presence: true
  end

  # Validations for school_managers are common to all agreements
  with_options if: :enforce_school_manager_validations? do
    validates :school_representative_full_name,
              :school_representative_role,
              :student_school,
              :student_birth_date,
              presence: true
    validates :school_representative_email,
              :student_legal_representative_full_name,
              :student_refering_teacher_email,
              :student_legal_representative_email,
              :student_full_name,
              presence: true,
              length: { minimum: 5, maximum: 100 }
    validates :organisation_representative_role,
              presence: true,
              length: { minimum: 2, maximum: 150 }
    validates :student_refering_teacher_full_name,
              presence: true,
              length: { minimum: 3, maximum: 100 } # includes "N/A"
    validates :student_address, length: { minimum: 5, maximum: 170 }
    validates :access_token, length: { is: 20 }
    validates :student_phone,
              :school_representative_phone,
              :student_legal_representative_phone,
              format: { with: /(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}/,
                        message: "Veuillez suivre les exemples ci-après : '0611223344' ou '+330611223344'" }
  end

  # Callbacks
  after_save :save_delegation_date

  aasm do
    state :draft, initial: true
    state :started_by_employer,
          :completed_by_employer,
          :started_by_school_manager,
          :validated,
          :signatures_started,
          :signed_by_all

    # employer starts filling the agreement saves but may not have completed it
    event :start_by_employer do
      transitions from: :draft,
                  to: :started_by_employer
    end

    # employer has completed filling the agreement
    event :complete do
      transitions from: %i[draft started_by_employer],
                  to: :completed_by_employer,
                  after: proc { |*_args|
                           notify_school_management_of_employer_completion(self)
                         }
    end

    # school_manager starts filling in but may not finish at once. He may save his progress
    event :start_by_school_manager do
      transitions from: :completed_by_employer,
                  to: :started_by_school_manager
    end

    # validate is a reserved keyword and finalize is used instead.
    # It means the agreement is ready to be signed by any of the parties
    event :finalize do
      transitions from: %i[completed_by_employer started_by_school_manager],
                  to: :validated,
                  after: proc { |*_args|
                           notify_signatures_enabled unless skip_notifications_when_system_creation
                         }
    end

    # helper
    event :back_to_started_by_school_manager do
      transitions from: %i[signatures_started validated],
                  to: :started_by_school_manager
    end

    event :sign do # sign after signature creation !
      transitions from: %i[validated signatures_started],
                  to: :signatures_started,
                  guard: :roles_not_signed_yet_present?,
                  after: proc { |*_args|
                    roles_not_signed_yet.present? &&
                      !skip_notifications_when_system_creation &&
                      notify_others_signatures_started
                  }
      transitions from: [:signatures_started],
                  to: :signed_by_all,
                  guard: :roles_not_signed_yet_blank?,
                  after: proc { |*_args|
                           notify_others_signatures_finished(self) unless skip_notifications_when_system_creation
                         }
    end
  end

  delegate :student,               to: :internship_application
  delegate :internship_offer,      to: :internship_application
  delegate :employer,              to: :internship_offer
  delegate :school,                to: :student
  delegate :school_manager,        to: :school
  delegate :internship_offer_area, to: :internship_offer
  delegate :from_multi?,           to: :internship_offer

  scope :having_school_manager, lambda {
    kept.joins(internship_application: { student: :school })
        .merge(School.with_school_manager)
  }

  scope :filtering_discarded_students, lambda {
    joins(internship_application: :student)
      .where(internship_application: { users: { discarded_at: nil } })
  }

  scope :troisieme_grades, lambda {
    joins(internship_application: { student: :grade })
      .where(grades: { id: Grade.troisieme.id })
  }
  scope :seconde_grades, lambda {
    joins(internship_application: { student: :grade })
      .where(grades: { id: Grade.seconde.id })
  }

  def enforce_teacher_validations?
    enforce_teacher_validations == true
  end

  def enforce_school_manager_validations?
    enforce_school_manager_validations == true
  end

  def enforce_employer_validations?
    enforce_employer_validations == true
  end

  def valid_working_hours_fields
    if weekly_planning?
      unless valid_weekly_planning?
        errors.add(:same_daily_planning,
                   'Veuillez compléter les horaires et repas de la journée de stage')
      end
    elsif daily_planning?
      unless valid_daily_planning?
        errors.add(:weekly_planning,
                   'Veuillez compléter les horaires et repas de la semaine de stage')
      end
    else
      errors.add(:weekly_planning, 'Veuillez compléter les horaires du stage')
    end
  end

  def weekly_planning?
    weekly_hours&.any?(&:present?)
  end
  alias_method :valid_weekly_planning?, :weekly_planning?

  def daily_planning?
    return false if daily_hours.blank?

    daily_hours.values.flatten.any? { |v| v.present? }
  end

  def valid_daily_planning?
    # daily_hours sample data :
    # {"jeudi"=>["11:45", "16:00"], "lundi"=>["11:45", "15:45"], "mardi"=>["12:00", "16:00"], "samedi"=>["", ""], "mercredi"=>["12:00", "16:00"], "vendredi"=>["", ""]}
    # {"jeudi"=>"a good meal", "lundi"=>"a good meal", "mardi"=>"a good meal", "samedi"=>"a good meal "mercredi"=>"a good meal", "vendredi"=>"a good meal"}
    valid_presence_days_count = daily_hours.values.inject(0) do |count, v|
      count += 1 if v.first.present? && v.second.present?
      count
    end

    valid_presence_days_count >= MIN_PRESENCE_DAYS &&
      (weekly_lunch_break.present? || lunch_break.present?)
  end

  def presenter(user:)
    Presenters::InternshipAgreement.new(self, user)
  end

  def archive
    fields_to_reset = {
      organisation_representative_full_name: 'NA',
      school_representative_full_name: 'NA',
      student_full_name: 'NA',
      student_class_room: 'NA',
      student_school: 'NA',
      tutor_full_name: 'NA',
      siret: 'NA',
      tutor_role: 'NA',
      tutor_email: 'NA',
      organisation_representative_role: 'NA',
      student_address: 'NA',
      student_phone: 'NA',
      school_representative_phone: 'NA',
      student_refering_teacher_phone: 'NA',
      student_legal_representative_email: 'NA',
      student_refering_teacher_email: 'NA',
      student_legal_representative_full_name: 'NA',
      student_refering_teacher_full_name: 'NA',
      student_legal_representative_2_full_name: 'NA',
      student_legal_representative_2_email: 'NA',
      student_legal_representative_2_phone: 'NA',
      school_representative_role: 'NA',
      school_representative_email: 'NA',
      student_legal_representative_phone: 'NA'
    }
    update_columns(fields_to_reset)
    discard! unless discarded?
  end

  def school_management_representative
    signatory_representative = signatures.find_by(signatory_role: Signature::SCHOOL_MANAGEMENT_SIGNATORY_ROLE)
    return signatory_representative.signator unless signatory_representative.nil?
    return school.management_representative if school.management_representative

    nil
  end

  def notify_others_signatures_started
    GodMailer.notify_others_signatures_started_email(
      internship_agreement: self,
      missing_signatures_recipients: missing_signatures_recipients,
      last_signature: signatures&.last
    ).deliver_later
  end

  def legal_representative_emails?
    emails = []
    emails << student_legal_representative_email if student_legal_representative_email.present?
    emails << student_legal_representative_2_email if student_legal_representative_2_email.present?
    emails.uniq.compact.any?
  end

  def legal_representative_data
    hash = { }
     if student_legal_representative_email.present? && student_legal_representative_full_name.present?
       hash[:student_legal_representative] = {email: student_legal_representative_email, nr: 1}
     end
     if student_legal_representative_2_email.present? && student_legal_representative_2_full_name.present?
       hash[:student_legal_representative_2] = {email: student_legal_representative_2_email, nr: 2}
     end
    hash
  end

  def legal_representative_count
    legal_representative_data.size
  end

  private

  def notify_signatures_enabled
    GodMailer.notify_signatures_can_start_email(
      internship_agreement: self
    ).deliver_later
    if Flipper.enabled?(:student_signature)
      legal_representative_data.values.each do |representative|
        GodMailer.notify_student_legal_representatives_can_sign_email(
          internship_agreement: self,
          representative: representative
        ).deliver_later
      end
    end
  end

  def notify_others_signatures_finished(agreement)
    GodMailer.notify_others_signatures_finished_email(internship_agreement: agreement)
             .deliver_later
  end

  def notify_school_management_of_employer_completion(agreement)
    SchoolManagerMailer.internship_agreement_completed_by_employer_email(
      internship_agreement: agreement
    ).deliver_later
  end

  rails_admin do
    weight 14
    navigation_label 'Offres'

    list do
      field :id
      field :internship_application
      field :aasm_state
    end
  end

  def save_delegation_date
    return unless student.school.delegation_date.blank?

    student.school.reload.update(delegation_date: delegation_date)
  end

  def at_least_daily_hours_or_weekly_hours
    if daily_hours.blank? && weekly_hours.blank?
      errors.add(:base, "Vous devez fournir soit les heures hebdomadaires, soit les heures journalières.")
    end
  end
end
