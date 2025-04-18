FactoryBot.define do
  factory :entreprise do
    internship_occupation
    sector
    group { create(:group, is_public: true) }
    is_public { true }
    siret { FFaker::CompanyFR.siret }
    employer_name { FFaker::CompanyFR.name }
    employer_chosen_name { FFaker::CompanyFR.name }
    entreprise_full_address { FFaker::AddressFR.full_address }
    entreprise_chosen_full_address { FFaker::AddressFR.full_address }
    entreprise_coordinates { Coordinates.paris }
    contact_phone { FFaker::PhoneNumberFR.phone_number }
    workspace_conditions { FFaker::Lorem.paragraph }
    workspace_accessibility { FFaker::Lorem.paragraph }

    trait :private do
      is_public { false }
      group_id { nil }
    end

    trait :public do
    end
  end
end
