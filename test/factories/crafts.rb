FactoryBot.define do
  factory :craft do
    craft_field
    name { "Craft_#{('a'..'z').to_a.shuffle.first(5).join}" }
    number {(10_000..99_999).to_a.sample}
  end
end
