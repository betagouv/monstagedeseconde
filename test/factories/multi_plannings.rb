FactoryBot.define do
  factory :multi_planning do
    multi_coordinator { association :multi_coordinator }
    max_candidates { 5 }
    weekly_hours { ["Lundi-Vendredi 9h-17h"] }
    lunch_break { "12h-13h" }
    rep { false }
    qpv { false }
  end
end
