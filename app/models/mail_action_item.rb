class MailActionItem < ApplicationRecord
  # id bigint NOT NULL,
  # action_name character varying,
  # user_id bigint NOT NULL,
  # first_seen_at timestamp(6) without time zone,
  # stale_at timestamp(6) without time zone,
  # last_notified_at timestamp(6) without time zone,
  # resolved_at timestamp(6) without time zone,
  # payload jsonb,
  # created_at timestamp(6) without time zone NOT NULL,
  # updated_at timestamp(6) without time zone NOT NULL,
  # action_type public.action_type,
  # urgency_level public.urgency_level

  DEFAULT_NEW_INTERNSHIPS_APPLICATIONS_URGENCY_LEVEL = "medium"
  DEFAULT_NEW_INTERNSHIPS_APPLICATIONS_MAX_DELIVERIES_COUNT = 1


  # Associations
  belongs_to :user
  belongs_to :internship_offer, optional: true
  belongs_to :internship_application, optional: true
  belongs_to :internship_agreement, optional: true
  # validations
  validates_presence_of :user_id,
                        :action_type
  # enums
  enum :action_type, {
    pending_application:     "pending_application",
    agreement_to_complete:   "agreement_to_complete",
    agreement_to_sign:       "agreement_to_sign",
    agreement_signed_by_all: "agreement_signed_by_all"
  }, validate: true
  enum :urgency_level, {
    low: "low",
    medium: "medium",
    high: "high",
    critical: "critical"
  }, validate: true

  # scopes
  scope :pending, -> { where(resolved_at: nil) }
  scope :resolved, -> { where.not(resolved_at: nil) }
  scope :overdue, -> { pending.where("stale_at < ?", Time.current) }
  scope :not_overdue, -> { pending.where("stale_at >= ?", Time.current) }
  scope :with_action_type, ->(type) { where(action_type: type) }
  scope :with_urgency_level, ->(level) { where(urgency_level: level) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # class methods
  def self.involved_user_ids
    pluck(:user_id).uniq
  end
  # instance methods

  def presenter
    Presenters::MailActionItem.new(self)
  end
end
