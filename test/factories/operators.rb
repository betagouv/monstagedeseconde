# frozen_string_literal: true

FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "operator-#{n}" }
    api_full_access { false }
    target_count { 0 }
    masked_data { false }
    realized_count do
      {
        '2022' => {
          'total': '10',
          'onsite': '5',
          'online': '3',
          'hybrid': '2',
          'worshop': '1',
          'private': '8',
          'public': '2'
        }
      }
    end
    factory :operator_with_departments, parent: :operator do |operator|
      after(:create) do |ope|
        ope.departments << Department.find_by(code: '60')
        ope.departments << Department.find_by(code: '78')
      end
    end
  end
end
