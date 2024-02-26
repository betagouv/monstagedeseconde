# frozen_string_literal: true

FactoryBot.define do
  factory :class_room do
    school
    name { '2de A' }
  end
end
