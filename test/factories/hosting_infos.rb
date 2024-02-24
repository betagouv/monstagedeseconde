FactoryBot.define do
  factory :hosting_info do
    employer { create(:employer) }
    weeks_count { 0 }
    max_candidates { 2 }
    max_students_per_group { 1 }
  end
end
