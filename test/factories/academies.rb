FactoryBot.define do
  factory :academy do
    name { "Ile de France" }
    email_domain { "ac-paris.fr" }
    academy_region { create(:academy_region) }
  end
end
