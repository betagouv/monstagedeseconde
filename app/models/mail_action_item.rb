class MailActionItem < ApplicationRecord
  include MailActionConfigurable

  # Associations
  belongs_to :recipient, polymorphic: true
  belongs_to :internship_offer, optional: true
  belongs_to :internship_application, optional: true
  belongs_to :internship_agreement, optional: true
  # validations
  validates_presence_of :recipient_id,
                        :recipient_type,
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
  scope :for_user, ->(user_id) { where(recipient_id: user_id) }
  scope :for_employers, -> { where(recipient_type: "Users::Employer") }
  scope :for_employer, ->(employer_id) { where(recipient_type: "Users::Employer", recipient_id: employer_id) }
  scope :for_school_management_team, -> { where(recipient_type: "Users::SchoolManagement") }
  scope :for_school_management, ->(school_management_id) {
    where(recipient_type: "Users::SchoolManagement", recipient_id: school_management_id)
  }
  scope :for_school_managers, -> do
    where(recipient_type: "Users::SchoolManagement")
    .where(recipient_id: Users::SchoolManagement.where(role: :school_manager).pluck(:id))
  end

  def self.create_by_name!(name, **kwargs)
    config = ACTION_CONFIGS.fetch(name) { raise ArgumentError, "Unknown MailActionItem name: #{name}" }
    attrs = config.transform_values { |v| v.respond_to?(:call) ? v.call : v }
    allowed_keys = %i[recipient internship_offer internship_offer_id
                      internship_application internship_application_id
                      internship_agreement internship_agreement_id stale_at]
    attrs.merge!(kwargs.slice(*allowed_keys))

    recipient = attrs.delete(:recipient) || kwargs[:recipient]
    lookup = { action_name: name,
               recipient_type: recipient&.class&.name,
               recipient_id: recipient&.id,
               internship_agreement_id: attrs[:internship_agreement_id],
               internship_application_id: attrs[:internship_application_id] }.compact
    record = find_or_initialize_by(lookup)
    record.assign_attributes(attrs.merge(action_name: name))
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

  rails_admin do
    weight 13
    navigation_label "Divers"

    list do
      field :id
      field :recipient
      field :action_name
      field :action_type
      field :urgency_level
      field :stale_at
      field :resolved_at
      field :deliveries_ratio, :string do
        formatted_value { "#{bindings[:object].deliveries_count} / #{bindings[:object].max_deliveries_count}" }
        label "Envois"
      end
      # make a link to internship_application or internship_agreement if present
      field :internship_application
      field :internship_agreement
      field :created_at
      field :updated_at
    end

    show do
      field :id
      field :recipient
      field :action_name
      field :action_type
      field :urgency_level
      field :stale_at
      field :resolved_at
      field :deliveries_ratio, :string do
        formatted_value { "#{bindings[:object].deliveries_count} / #{bindings[:object].max_deliveries_count}" }
        label "Envois"
      end
      field :internship_application
      field :internship_agreement_id
      field :created_at
      field :updated_at
    end

    edit do
      field :recipient do
        read_only true
        help "The recipient of the action item (cannot be changed after creation)"
      end

      field :action_name do
        read_only true
        help "The name of the action (cannot be changed after creation)"
      end

      field :action_type do
        read_only true
        help "The type of the action (cannot be changed after creation)"
      end

      field :urgency_level, :enum do
        enum do
          MailActionItem.urgency_levels.keys.map { |level| [ level.humanize, level ] }.to_h
        end

        help "The urgency level of the action item"
      end

      field :stale_at do
        help "The date and time when the action item becomes stale/overdue"
      end

      field :resolved_at do
        help "The date and time when the action item was resolved (can be set manually for testing purposes)"
      end

      field :deliveries_count do
        read_only true
        help "The number of times this action item has been delivered (cannot be changed manually)"
      end

      field :max_deliveries_count do
        help "The maximum number of times this action item can be delivered before it is automatically resolved"
      end
    end
  end
end
