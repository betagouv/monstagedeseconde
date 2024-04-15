FactoryBot.define do
  factory :craft_field do
    name { "CraftField_#{('a'..'z').to_a.shuffle.first(5).join}" }
    sequence(:letter) { |n| (('A'..'Z').to_a + ('a'..'z').to_a)[n] }
  end
end
