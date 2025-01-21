FactoryBot.define do
  factory :waiting_list_entry do
    email { Faker::Internet.email }
  end
end
