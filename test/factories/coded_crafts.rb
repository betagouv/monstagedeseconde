FactoryBot.define do
  factory :coded_craft do
    detailed_craft
    name { "CodedCraft_#{('a'..'z').to_a.shuffle.first(5).join}" }
    ogr_code {(100_000..999_999).to_a.sample}
  end
end
