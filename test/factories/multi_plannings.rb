FactoryBot.define do
  factory :multi_planning do
    multi_coordinator { association :multi_coordinator }
    max_candidates { 5 }
    weekly_hours { ["Lundi-Vendredi 9h-17h"] }
    lunch_break { "12h-13h" }
    rep { false }
    qpv { false }
    
    after(:build) do |multi_planning|
      if multi_planning.weeks.empty?
        week = Week.selectable_from_now_until_end_of_school_year.first || Week.current
        multi_planning.weeks << week
      end
    end
  end
end
