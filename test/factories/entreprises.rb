FactoryBot.define do
  factory :entreprise do
    internship_occupation
    siret { FFaker::CompanyFR.siret }
    is_public { true }
    employer_name { FFaker::CompanyFR.name }
    employer_chosen_name { FFaker::CompanyFR.name }
    entreprise_full_address { FFaker::AddressFR.full_address }
    entreprise_chosen_full_address { FFaker::AddressFR.full_address }
    entreprise_coordinates { Coordinates.paris }
    tutor_first_name { FFaker::NameFR.first_name }
    tutor_last_name { FFaker::NameFR.last_name }
    tutor_email { FFaker::Internet.email }
    tutor_phone { FFaker::PhoneNumberFR.phone_number }
    tutor_function { 'Chef de clinique' }
    sector { build(:sector) }
  end
end
