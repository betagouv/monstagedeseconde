FactoryBot.define do
  factory :department do
    code { "75" }
    name { "Paris" }
    academy { create(:academy) }
  end
end
