# frozen_string_literal: true

FactoryBot.define do
  factory :class_room do
    school
    name { '2de A' }
    grade { create(:grade, :troisieme) }

    trait :quatrieme do
      name { '4e C' }
      grade { Grade.quatrieme }
    end

    trait :troisieme do
      name { '3e B' }
      grade { Grade.troisieme }
    end

    trait :seconde do
      name { '2de A' }
      grade { Grade.seconde }
    end
  end
end
