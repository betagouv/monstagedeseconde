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
        action_type:          :pending_internship_application,
        urgency_level:        "low",
        max_deliveries_count: 3,
        stale_at:             -> { 7.days.from_now }
      },
      "canceled_internship_application_by_student" => {
        action_type:          :pending_internship_application,
        urgency_level:        "medium",
        max_deliveries_count: 1,
        stale_at:             -> { 30.days.from_now }
      },
      "restored_internship_application" => {
        action_type:          :pending_internship_application,
        urgency_level:        "medium",
        max_deliveries_count: 1,
        stale_at:             -> { 30.days.from_now }
      },
      "cancel_by_student_confirmation" => {
        action_type:          :pending_internship_application,
        urgency_level:        "high",
        max_deliveries_count: 1,
        stale_at:             -> { 30.days.from_now }
      },
      "candidate_chose_another_internship" => {
        action_type:          :pending_internship_application,
        urgency_level:        "high",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      },
      "candidate_restored_by_student" => {
        action_type:          :pending_internship_application,
        urgency_level:        "medium",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      },
      "canceled_internship_application" => {
        action_type:          :pending_internship_application,
        urgency_level:        "low",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      },
      "internship_application_transfered" => {
        action_type:          :pending_internship_application,
        urgency_level:        "medium",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      }
    }.freeze

    PENDING_AGREEMENT_CONFIGS = {
      "agreement_signed_by_another" => {
        action_type:          :pending_internship_agreement,
        urgency_level:        "low",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      },
      "agreement_to_sign" => {
        action_type:          :pending_internship_agreement,
        urgency_level:        "medium",
        max_deliveries_count: 2,
        stale_at:             -> { 7.days.from_now }
      }
    }.freeze

    PENDING_INTERNSHIP_OFFER_CONFIGS = {
      "internship_offer_unpublished" => {
        action_type:          :pending_internship_offer,
        urgency_level:        "low",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      },
      "internship_offer_removed" => {
        action_type:          :pending_internship_offer,
        urgency_level:        "high",
        max_deliveries_count: 1,
        stale_at:             -> { 7.days.from_now }
      }
    }.freeze

    ACTION_CONFIGS = PENDING_APPLICATION_CONFIGS
                       .merge(PENDING_AGREEMENT_CONFIGS)
                       .merge(PENDING_INTERNSHIP_OFFER_CONFIGS)
                       .freeze
  end
end
