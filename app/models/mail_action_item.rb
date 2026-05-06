class MailActionItem < ApplicationRecord
  include MailActionConfigurable

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
    pending_application:                   "pending_application",
    agreement_to_complete:                 "agreement_to_complete",
    agreement_to_sign:                     "agreement_to_sign",
    agreement_signed_by_all:               "agreement_signed_by_all",
    candidate_chose_another_internship:    "candidate_chose_another_internship",
    candidate_restored_by_student:         "candidate_restored_by_student",
    canceled_internship_application:       "canceled_internship_application",
    agreement_signed_by_another:           "agreement_signed_by_another",
    internship_application_transfered:     "internship_application_transfered",
    internship_offer_unpublished:          "internship_offer_unpublished",
    internship_offer_removed:              "internship_offer_removed"
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

  def self.create_by_name!(name, **kwargs)
    config = ACTION_CONFIGS.fetch(name) { raise ArgumentError, "Unknown MailActionItem name: #{name}" }
    attrs = config.transform_values { |v| v.respond_to?(:call) ? v.call : v }
    allowed_keys = %i[user user_id internship_offer internship_offer_id
                      internship_application internship_application_id
                      internship_agreement internship_agreement_id stale_at]
    attrs.merge!(kwargs.slice(*allowed_keys))
    record = new(action_name: name, **attrs)
    record.save!
    record
  end

  # class methods
  def self.involved_user_ids
    pluck(:user_id).uniq
  end
  # instance methods

  def presenter
    Presenters::MailActionItem.new(self)
  end
end
