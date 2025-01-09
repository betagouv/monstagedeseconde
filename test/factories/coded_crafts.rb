FactoryBot.define do
  factory :coded_craft do
    detailed_craft
    name { "CodedCraft_#{('a'..'z').to_a.shuffle.first(5).join}" }
    ogr_code {(10_000..99_999).to_a.sample}
  end
end
