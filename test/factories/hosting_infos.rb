FactoryBot.define do
  factory :hosting_info do
    employer { create(:employer) }
    weeks_count { 0 }
    max_candidates { 2 }
  end
end
