FactoryBot.define do
  factory :internship_application_state_change do
    association :internship_application
    association :author
    from_state { 'submitted' }
    to_state { 'read' }
    metadata {}
  end
end
