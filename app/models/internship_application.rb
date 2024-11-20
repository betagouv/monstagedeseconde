# frozen_string_literal: true

# application from student to internship_offer ; linked with weeks
require 'sti_preload'
class InternshipApplication < ApplicationRecord
  include StiPreload
  include AASM
  include Rails.application.routes.url_helpers
  PAGE_SIZE = 10
  EXPIRATION_DURATION = 15.days
  EXTENDED_DURATION = 15.days
  MAGIC_LINK_EXPIRATION_DELAY = 5.days
  RECEIVED_STATES = %w[submitted read_by_employer expired transfered]
  PENDING_STATES = RECEIVED_STATES + %w[validated_by_employer] - %w[expired]
  REJECTED_STATES = %w[rejected canceled_by_employer canceled_by_student canceled_by_student_confirmation]
  EXPIRED_STATES = %w[expired expired_by_student]
  APPROVED_STATES = %w[approved validated_by_employer]
  ORDERED_STATES_INDEX = %w[
    expired
    canceled_by_student_confirmation
    canceled_by_student
    rejected
    expired_by_student
    canceled_by_employer
    submitted
    read_by_employer
    transfered
    validated_by_employer
    approved
  ]
  NOT_MODIFIABLE_STATES = %w[drafted submitted read_by_employer transfered validated_by_employer approved]
  RE_APPROVABLE_STATES = %w[rejected canceled_by_employer canceled_by_student expired_by_student expired]

  attr_accessor :sgid

  belongs_to :weekly_internship_offer,
             class_name: 'InternshipOffers::WeeklyFramed',
             foreign_key: 'internship_offer_id'
  belongs_to :internship_offer, polymorphic: true
  belongs_to :student, class_name: 'Users::Student',
                       foreign_key: 'user_id'
  has_one :internship_agreement
  has_many :state_changes, class_name: 'InternshipApplicationStateChange'
  has_many :internship_application_weeks
  has_many :weeks, through: :internship_application_weeks

  delegate :update_all_counters, to: :internship_application_counter_hook
  delegate :name, to: :student, prefix: true
  delegate :employer, to: :internship_offer
  delegate :remaining_seats_count, to: :internship_offer

  after_save :update_all_counters
  accepts_nested_attributes_for :student, update_only: true

  # has_rich_text :approved_message
  # has_rich_text :rejected_message
  # has_rich_text :canceled_by_employer_message
  # has_rich_text :canceled_by_student_message
  # has_rich_text :motivation

  paginates_per PAGE_SIZE

  # Validations
  validates :student_phone,
            format: {
              with: /\A\+?(33|262|594|596|687|689)?\s?0?(6|7)\s?(\d{2,3}\s?){1,3}\d{2,3}\z/,
              message: 'Veuillez modifier le numéro de téléphone mobile'
            },
            allow_blank: true
  validates :student_email,
            format: { with: Devise.email_regexp },
            allow_blank: true

  # Callbacks
  before_create :set_submitted_at
  after_create :notify_users
  after_save :update_student_profile

  #
  # Triggers scopes (used for transactional mails)
  #

  # reminders after 7 days, 14 days and none afterwards
  scope :remindable, lambda {
    passed_sumitted = where(submitted_at: 16.days.ago..7.days.ago)
                      .where(canceled_at: nil)
                      .or(submitted.where(submitted_at: 16.days.ago..7.days.ago)
                                   .where(canceled_at: nil))
    starting = passed_sumitted.where('pending_reminder_sent_at is null')
    current  = passed_sumitted.where('pending_reminder_sent_at < :date', date: 7.days.ago)
    starting.or(current)
  }

  scope :expiration_not_extended_states, lambda {
    where(aasm_state: %w[submitted read_by_employer])
  }

  scope :expirable, lambda {
    simple_duration = InternshipApplication::EXPIRATION_DURATION
    expiration_not_extended_states.where('submitted_at < :date', date: simple_duration.ago)
  }

  scope :filtering_discarded_students, lambda {
    joins(:student).where(student: { discarded_at: nil })
  }

  #
  # Ordering scopes (used for ordering in ui)
  #
  # TODO remove column convention_signed_at
  scope :order_by_aasm_state, lambda {
    select("#{table_name}.*")
      .select(%(
      CASE
        WHEN aasm_state = 'convention_signed' THEN 0
        WHEN aasm_state = 'drafted' THEN 1
        WHEN aasm_state = 'approved' THEN 2
        WHEN aasm_state = 'submitted' THEN 3
        WHEN aasm_state = 'rejected' THEN 4
        ELSE 0
      END as orderable_aasm_state
    ))
      .order('orderable_aasm_state')
  }

  scope :order_by_aasm_state_for_student, lambda {
    select("#{table_name}.*")
      .select(%(
      CASE
        WHEN aasm_state = 'validated_by_employer' THEN 0
        ELSE 1
      END as orderable_aasm_state
    ))
      .order('orderable_aasm_state')
  }

  scope :no_date_index, lambda {
    where.not(aasm_state: [:drafted])
         .includes(
           :student,
           :internship_offer
         ).default_order
  }

  scope :through_teacher, lambda { |teacher:|
    joins(student: :class_room).where('users.class_room_id = ?', teacher.class_room_id)
  }

  scope :with_active_students, lambda {
    joins(:student).where('users.discarded_at is null')
  }

  scope :not_drafted, -> { where.not(aasm_state: 'drafted') }

  scope :approved_or_signed, lambda {
    applications = InternshipApplication.arel_table
    where(applications[:aasm_state].in(%w[approved signed]))
  }

  scope :pending_for_employers, lambda {
    applications = InternshipApplication.arel_table
    where(applications[:aasm_state].in(%w[submitted read_by_employer]))
  }

  scope :current_school_year, lambda {
    where(created_at: SchoolYear::Current.new.beginning_of_period..SchoolYear::Current.new.end_of_period)
  }

  #
  # Other stuffs
  #
  scope :default_order, -> { order(updated_at: :desc) }
  scope :for_user, ->(user:) { where(user_id: user.id) }
  scope :not_by_id, ->(id:) { where.not(id:) }

  scope :weekly_framed, -> { where(type: InternshipApplications::WeeklyFramed.name) }

  # add an additional delay when sending email using richtext
  # sometimes email was sent before action_texts_rich_text was persisted
  def deliver_later_with_additional_delay
    yield.deliver_later(wait: 1.second)
  end

  aasm do
    state :submitted, initial: true
    state :read_by_employer,
          :transfered,
          :validated_by_employer,
          :approved,
          :rejected,
          :expired,
          :expired_by_student,
          :canceled_by_employer,
          :canceled_by_student,
          :canceled_by_student_confirmation

    event :submit do
      transitions from: :drafted,
                  to: :submitted,
                  after: proc { |user, metadata = {}|
                           update!("submitted_at": Time.now.utc)
                           deliver_later_with_additional_delay do
                             EmployerMailer.internship_application_submitted_email(internship_application: self)
                           end
                           Triggered::StudentSubmittedInternshipApplicationConfirmationJob.perform_later(self)
                           setSingleApplicationReminderJobs
                           record_state_change(user, {})
                         }
    end

    event :read do
      transitions from: :submitted, to: :read_by_employer,
                  after: proc { |user, *_args|
                           update!("read_at": Time.now.utc)
                           record_state_change(user, {})
                         }
    end

    event :transfer do
      transitions from: %i[submitted read_by_employer],
                  to: :transfered,
                  after: proc { |user, *_args|
                           update!("transfered_at": Time.now.utc)
                           record_state_change(user, {})
                         }
    end

    event :employer_validate do
      from_states = %i[read_by_employer
                       submitted
                       transfered
                       cancel_by_employer
                       rejected]
      transitions from: from_states,
                  to: :validated_by_employer,
                  after: proc { |user, *_args|
                    update!("validated_by_employer_at": Time.now.utc, aasm_state: :validated_by_employer)
                    reload
                    after_employer_validation_notifications
                    CancelValidatedInternshipApplicationJob.set(wait: 15.days).perform_later(internship_application_id: id)
                    record_state_change(user, {})
                  }
    end

    event :approve do
      transitions from: %i[validated_by_employer],
                  to: :approved,
                  after: proc { |user, *_args|
                    update!("approved_at": Time.now.utc)
                    student_approval_notifications
                    cancel_all_pending_applications
                    record_state_change(user, {})
                  }
    end

    event :cancel_by_student_confirmation do
      from_states = %i[submitted
                       read_by_employer
                       transfered
                       validated_by_employer ]
      transitions from: from_states,
                  to: :canceled_by_student_confirmation,
                  after: proc { |user, *_args|
                    if employer_aware_states.include?(aasm_state)
                      # Employer need to be notified
                      EmployerMailer.internship_application_approved_for_an_other_internship_offer_email(internship_application: self).deliver_later
                    end
                    record_state_change(user, {})
                  }
    end

    event :reject do
      from_states = %i[read_by_employer
                       submitted
                       transfered
                       validated_by_employer ]
      transitions from: from_states,
                  to: :rejected,
                  after: proc { |user, *_args|
                           update!("rejected_at": Time.now.utc)
                           if student.email.present?
                             deliver_later_with_additional_delay do
                               StudentMailer.internship_application_rejected_email(internship_application: self)
                             end
                           end
                           record_state_change(user, {})
                         }
    end

    event :cancel_by_employer do
      from_states = %i[drafted
                       submitted
                       read_by_employer
                       transfered
                       validated_by_employer
                       approved ]
      transitions from: from_states,
                  to: :canceled_by_employer,
                  after: proc { |user, *_args|
                           update!("canceled_at": Time.now.utc)
                           if student.email.present?
                             deliver_later_with_additional_delay do
                               StudentMailer.internship_application_canceled_by_employer_email(internship_application: self)
                             end
                           end
                           internship_agreement&.destroy
                           record_state_change(user, {})
                         }
    end

    event :cancel_by_student do
      from_states = %i[submitted
                       read_by_employer
                       validated_by_employer
                       approved]
      transitions from: from_states,
                  to: :canceled_by_student,
                  after: proc { |user, *_args|
                           update!("canceled_at": Time.now.utc)
                           deliver_later_with_additional_delay do
                             EmployerMailer.internship_application_canceled_by_student_email(
                               internship_application: self
                             )
                           end
                           internship_agreement&.destroy
                           record_state_change(user, {})
                         }
    end

    event :expire do
      transitions from: %i[submitted read_by_employer validated_by_employer],
                  to: :expired,
                  after: proc { |user, *_args|
                           update!(expired_at: Time.now.utc)
                           # notitify_student
                           Triggered::StudentExpiredInternshipApplicationsNotificationJob.perform_later(self)
                           record_state_change(user, {})
                         }
    end

    event :expire_by_student do
      transitions from: %i[validated_by_employer read_by_employer submitted drafted],
                  to: :expired_by_student,
                  after: proc { |user, *_args|
                           update!(expired_at: Time.now.utc)
                           record_state_change(user, {})
                         }
    end
  end

  def set_submitted_at
    self.submitted_at = Time.now.utc if submitted_at.nil?
  end

  def notify_users
    EmployerMailer.internship_application_submitted_email(internship_application: self).deliver_later(wait: 1.second)
    Triggered::StudentSubmittedInternshipApplicationConfirmationJob.perform_later(self)

    return if student.internship_applications.count == 0

    Triggered::SingleApplicationReminderJob.set(wait: 2.days).perform_later(student.id)
    Triggered::SingleApplicationSecondReminderJob.set(wait: 5.days).perform_later(student.id)
  end

  def state_index
    ORDERED_STATES_INDEX.index(aasm_state)
  end

  def self.best_state(applications)
    return nil if applications.empty?

    max_ranking_state = applications.map(&:state_index).max
    ORDERED_STATES_INDEX[max_ranking_state]
  end

  def setSingleApplicationReminderJobs
    return unless student.internship_applications.count == 1

    Triggered::SingleApplicationReminderJob.set(wait: 2.days).perform_later(student.id)
    Triggered::SingleApplicationSecondReminderJob.set(wait: 5.days).perform_later(student.id)
  end

  def student_approval_notifications
    main_teacher = student.main_teacher
    arg_hash = {
      internship_application: self,
      main_teacher:
    }

    create_agreement if employer.agreement_signatorable?
    if main_teacher.present?
      deliver_later_with_additional_delay do
        MainTeacherMailer.internship_application_approved_with_agreement_email(**arg_hash)
      end
    end

    return unless missing_school_manager?

    UserMailer.missing_school_manager_warning_email(offer: internship_offer, student:)
              .deliver_later
  end

  def missing_school_manager?
    student.school && student.school.school_manager.nil?
  end

  def is_modifiable?
    NOT_MODIFIABLE_STATES.exclude?(aasm_state)
  end

  def is_re_approvable?
    # false if sutdent is anonymised or student has an approved application
    return false if student.anonymized? || student.internship_applications.where(aasm_state: 'approved').any?

    RE_APPROVABLE_STATES.include?(aasm_state)
  end

  def self.from_sgid(sgid)
    GlobalID::Locator.locate_signed(sgid)
  end

  def self.with_employer_explanations_states
    %w[rejected canceled_by_employer]
  end

  def after_employer_validation_notifications
    if type == 'InternshipApplications::WeeklyFramed' && student.main_teacher.present?
      deliver_later_with_additional_delay do
        MainTeacherMailer.internship_application_validated_by_employer_email(self)
      end
    end
    if student.email.present?
      deliver_later_with_additional_delay do
        StudentMailer.internship_application_validated_by_employer_email(internship_application: self)
      end
    end
    SendSmsStudentValidatedApplicationJob.perform_later(internship_application_id: id)
  end

  def selectable_weeks
    available_weeks = []
    if student.seconde_gt?
      available_weeks = internship_offer.weeks
    elsif student.troisieme_or_quatrieme?
      available_weeks = Week.selectable_from_now_until_end_of_school_year & internship_offer.weeks
    end
    available_weeks
  end

  def generate_token
    return if access_token.present?

    self.access_token = SecureRandom.hex(10)
    save
  end

  def create_agreement
    return unless internship_agreement_creation_allowed?

    agreement = Builders::InternshipAgreementBuilder.new(user: Users::God.new)
                                                    .new_from_application(self)
    agreement.skip_validations_for_system = true
    agreement.save!

    EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement:
    ).deliver_later
  end

  def internship_application_counter_hook
    case self
    when InternshipApplications::WeeklyFramed
      InternshipApplicationCountersHooks::WeeklyFramed.new(internship_application: self)
    else
      raise 'can not process stats for this kind of internship_application'
    end
  end

  def internship_application_aasm_message_builder(aasm_target:)
    case self
    when InternshipApplications::WeeklyFramed
      InternshipApplicationAasmMessageBuilders::WeeklyFramed.new(internship_application: self, aasm_target:)
    else
      raise 'can not build aasm message for this kind of internship_application'
    end
  end

  def student_is_male?
    student.gender == 'm'
  end

  def student_is_female?
    student.gender == 'f'
  end

  def previous_student_phone
    student.internship_applications
           .where.not(student_phone: nil)
           .last&.student_phone
  end

  def previous_student_email
    student.internship_applications
           .where.not(student_email: nil)
           .last&.student_email
  end

  def max_dunning_letter_count_reached?
    dunning_letter_count >= 1
  end

  def anonymize
    self.motivation = nil
    return unless student_phone || student_email

    self.student_phone = nil
    self.student_email = nil
    save
  end

  def short_target_url(sgid = nil)
    options = Rails.configuration.action_mailer.default_url_options
    target = dashboard_students_internship_application_url(
      student_id: student.id,
      id:,
      **options
    )
    target = "#{target}?student_id=#{student.id}"
    target = "#{target}&sgid=#{sgid}" if sgid
    UrlShrinker.short_url(url: target, user_id: student.id)
  end

  def sgid_short_url
    sgid = student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
    short_target_url(sgid)
  end

  # Used for prettier links in rails_admin
  def title
    'Candidature de ' + student_name
  end

  def cancel_all_pending_applications
    applications_to_cancel = student.internship_applications
                                    .where(aasm_state: InternshipApplication::PENDING_STATES)
    if student.seconde_gt?
      if internship_offer.seconde_school_track_week_1?
        applications_to_cancel = applications_to_cancel.select do |application|
          offer = application.internship_offer
          offer.seconde_school_track_week_1? || offer.two_weeks_long?
        end
      end
      if internship_offer.seconde_school_track_week_2?
        applications_to_cancel = applications_to_cancel.select do |application|
          offer = application.internship_offer
          offer.seconde_school_track_week_2? || offer.two_weeks_long?
        end
      end
    end
    applications_to_cancel.each do |application|
      application.cancel_by_student_confirmation! unless application == self
    end
  end

  def filter_notified_emails
    original_employer = internship_offer.employer
    return employer.email unless employer.employer_like?
    return employer.email if employer.team.not_exists?

    potential_employers = original_employer.team.db_members
    emails = potential_employers.map do |potential_employer|
      should_notify?(potential_employer) ? potential_employer.email : nil
    end
    emails.compact
  end

  rails_admin do
    weight 14
    navigation_label 'Offres'

    list do
      field :id
      field :student
      field :internship_offer
      field :aasm_state, :state
    end
  end

  def presenter(user)
    @presenter ||= Presenters::InternshipApplication.new(self, user)
  end

  def response_message
    rejected_message || approved_message || canceled_by_employer_message || canceled_by_student_message
  end

  def has_been(state)
    state_changes.select { |state_change| state_change.to_state == state }.last
  end

  private

  def should_notify?(employer)
    internship_offer.internship_offer_area
                    .area_notifications
                    .find_by(user_id: employer.id)
                    .notify
  end

  def internship_agreement_creation_allowed?
    # return false unless student.school&.school_manager&.email
    return false unless internship_offer.employer.employer_like?

    true
  end

  def employer_aware_states
    %w[read_by_employer validated_by_employer]
  end

  def phone_prefix
    # return '' if student.phone.blank? # TODO Check if this is necessary why removing prefix if phone is blank but will be updated

    prefix = '+33'
    ['+262', '+594', '+596', '+687', '+689'].each do |p|
      prefix = p if student.phone&.start_with?(p)
    end
    "#{prefix}0"
  end

  def update_student_profile
    student.update(
      legal_representative_full_name: student_legal_representative_full_name,
      legal_representative_email: student_legal_representative_email,
      legal_representative_phone: student_legal_representative_phone,
      address: student_address
    )
  end

  def record_state_change(author, metadata = {})
    return if aasm.from_state == aasm.to_state

    state_changes.create!(
      from_state: aasm.from_state,
      to_state: aasm.to_state,
      author_id: author.try(:id),
      author_type: author.try(:class).try(:name),
      metadata:
    )
  end
end
