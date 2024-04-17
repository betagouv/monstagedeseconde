FactoryBot.define do
  factory :academy do
    name { "Académie de Paris" }
    email_domain { "ac-paris.fr" }
    academy_region { create(:academy_region) }
  end
end
