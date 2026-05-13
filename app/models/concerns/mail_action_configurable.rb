# frozen_string_literal: true

module MailActionConfigurable
  extend ActiveSupport::Concern

  included do
    # ACTION_CONFIGS: single source of truth for create_by_name! defaults.
    # Keys are action names; each value must include :action_type, :urgency_level,
    # :max_deliveries_count and :stale_at (as a lambda).
    # To add a new action: add one entry here + the value to the enum in MailActionItem.
    PENDING_APPLICATION_CONFIGS = {
      "new_internship_application" => {
        urgency_level: "medium",
        max_deliveries_count: 2
      },
      "canceled_internship_application_by_student" => {
        urgency_level: "medium",
        max_deliveries_count: 1
      },
      "restored_internship_application" => {
        urgency_level: "medium",
        max_deliveries_count: 1
      },
      "cancel_by_student_confirmation" => {
        urgency_level: "high",
        max_deliveries_count: 1
      },
      "candidate_chose_another_internship" => {
        urgency_level: "high",
        max_deliveries_count: 1
      },
      "candidate_restored_by_student" => {
        urgency_level: "medium",
          max_deliveries_count: 1
      },
      "canceled_internship_application" => {
        urgency_level: "low",
        max_deliveries_count: 1
      },
      "internship_application_transfered" => {
        urgency_level: "medium",
        max_deliveries_count: 1
      }
    }.transform_values { |v| v.merge(action_type: :pending_internship_application) }.freeze

    PENDING_AGREEMENT_CONFIGS = {
      "agreement_signed_by_another" => {
        urgency_level: "low",
        max_deliveries_count: 1
      },
      "agreement_to_sign" => {
        urgency_level: "medium",
        max_deliveries_count: 1
      },
      "signatures_enabled" => {
        urgency_level: "medium",
        max_deliveries_count: 2
      },
      "agreement_signed_by_all" => {
        urgency_level: "medium",
        max_deliveries_count: 1
      }
    }.transform_values { |v| v.merge(action_type: :pending_internship_agreement) }.freeze

    PENDING_INTERNSHIP_OFFER_CONFIGS = {
      "internship_offer_unpublished" => {
        urgency_level: "low",
        max_deliveries_count: 1
      },
      "internship_offer_removed" => {
        urgency_level: "high",
        max_deliveries_count: 1
      }
    }.transform_values { |v| v.merge(action_type: :pending_internship_offer) }.freeze

    ACTION_CONFIGS = PENDING_APPLICATION_CONFIGS
                       .merge(PENDING_AGREEMENT_CONFIGS)
                       .merge(PENDING_INTERNSHIP_OFFER_CONFIGS)
                       .freeze
  end
end
