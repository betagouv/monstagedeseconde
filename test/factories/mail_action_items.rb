FactoryBot.define do
  factory :mail_action_item do
    internship_application { nil }
    internship_agreement { nil }
    user { internship_application&.internship_offer&.employer || create(:employer) }
    action_name { "default_action" }
    action_type { :pending_internship_application }
    urgency_level { :medium }
    stale_at { 7.days.from_now }
    resolved_at { nil }
    deliveries_count { 0 }
    max_deliveries_count { 1 }
  end
end
