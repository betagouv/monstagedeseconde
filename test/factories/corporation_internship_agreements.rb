FactoryBot.define do
  factory :corporation_internship_agreement do
    corporation { association :corporation }
    internship_agreement { association :internship_agreement }
    signed { false }
  end
end
