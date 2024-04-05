# frozen_string_literal: true

require_relative '../support/coordinates'

FactoryBot.define do
  factory :school do
    name { 'Lycée evariste Gallois' }
    coordinates { Coordinates.paris }
    city { 'Paris' }
    zipcode { '75015' }
    code_uai { '075' + rand(100_000).to_s.rjust(5, '0') }
    department { create(:department) }
    is_public { true }
    contract_code { "99" }
    legal_status { "Public" }

    trait :at_paris do
      city { 'Paris' }
      name { 'Parisian school' }
      coordinates { Coordinates.paris }
    end

    trait :at_bordeaux do
      city { 'bordeaux' }
      name { 'bordeaux school' }
      coordinates { Coordinates.bordeaux }
      zipcode { '33072' }
      before(:create) do |school|
        academy_region = AcademyRegion.find_or_create_by(name: 'Nouvelle-Aquitaine')
        academy = Academy.find_or_create_by(name: 'Bordeaux', email_domain: 'ac-bordeaux.fr', academy_region: academy_region)
        department = Department.find_or_create_by(code: '33', name: 'Gironde', academy: academy)
      end
    end

    trait :with_school_manager do
      school_manager { build(:school_manager) }
    end
  end

  factory :api_school, class: Api::School do
    name { 'Lycée evariste Gallois' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    zipcode { '75015' }
  end
end
