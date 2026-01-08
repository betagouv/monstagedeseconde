FactoryBot.define do
  factory :corporation do
    multi_corporation { association :multi_corporation }
    # sector { create(:sector, name: FFaker::Lorem.word) }

    siret { '11122233300000' }
    corporation_name { 'Octave ACME' }
    corporation_address { '18 rue du poulet, 75001 Paris' }
    corporation_city { 'Paris' }
    corporation_zipcode { '75018' }
    corporation_street { '18 rue du poulet' }

    internship_city { 'Paris' }
    internship_zipcode { '75018' }
    internship_street { '18 rue Lamarck' }
    internship_phone { '+330612345678' }
    internship_coordinates { RGeo::Geographic.spherical_factory(srid: 4326).point(2.3488, 48.8534) }

    employer_name { 'Michel Leblanc' }
    employer_role { 'DRH' }
    employer_email { 'referent@example.com' }
    employer_phone { '+330612345678' }

    tutor_name { 'John Doe' }
    tutor_role_in_company { 'Manager' }
    tutor_email { 'john.doe@example.com' }
    tutor_phone { '+330612345111' }
  end
end
