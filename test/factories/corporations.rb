# frozen_string_literal: true

FactoryBot.define do
  factory :corporation do
    multi_corporation { association :multi_corporation }
    # not good !
    # sector { is_public ? Sector.find_by(name: 'Fonction publique') : create(:sector, name: FFaker::Lorem.word) }
    sector { create(:sector, name: FFaker::Lorem.word) }
    # not good !
    
    siret { '11122233300000' }
    employer_name { 'Octave ACME' }
    employer_address { '18 rue du poulet, 75001 Paris' }
    city { 'Paris' }
    zipcode { '75018' }
    street { '18 rue du poulet' }
    phone { '+330612345678' }
    internship_city { 'Paris' }
    internship_zipcode { '75018' }
    internship_street { '18 rue Lamarck' }
    internship_phone { '+330612345678' }
    tutor_name { 'John Doe' }
    tutor_role_in_company { 'Manager' }
    tutor_email { 'john.doe@example.com' }
    tutor_phone { '+330612345111' }
  end
end
