class MailActionItem < ApplicationRecord
  include MailActionConfigurable

  # Associations
  belongs_to :recipient, polymorphic: true
  belongs_to :internship_offer, optional: true
  belongs_to :internship_application, optional: true
  belongs_to :internship_agreement, optional: true
  # validations
  validates_presence_of :recipient_id, :recipient_type,
                        :action_type
  # enums
  enum :action_type, {
    pending_internship_offer:       "pending_internship_offer",
    pending_internship_application: "pending_internship_application",
    pending_internship_agreement:   "pending_internship_agreement"
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
  scope :with_urgency_levels, ->(levels) { where(urgency_level: levels) }
  scope :for_recipient, ->(recipient) { where(recipient: recipient) }
  scope :for_users, -> { where(recipient_type: "User") }
  scope :for_user, ->(user_id) { where(recipient_type: "User", recipient_id: user_id) }

  def self.create_by_name!(name, **kwargs)
    config = ACTION_CONFIGS.fetch(name) { raise ArgumentError, "Unknown MailActionItem name: #{name}" }
    attrs = config.transform_values { |v| v.respond_to?(:call) ? v.call : v }
    allowed_keys = %i[recipient internship_offer internship_offer_id
                      internship_application internship_application_id
                      internship_agreement internship_agreement_id stale_at]
    attrs.merge!(kwargs.slice(*allowed_keys))
    record = new(action_name: name, **attrs)
    record.save!
    record
  end

  # class methods
  def self.involved_user_ids
    where(recipient_type: "User").pluck(:recipient_id).uniq
  end
  # instance methods

  def presenter
    Presenters::MailActionItem.new(self)
  end
end
