# frozen_string_literal: true

require_relative '../support/coordinates'

FactoryBot.define do
  factory :school do
    name { 'Lycée evariste Gallois' }
    coordinates { Coordinates.paris }
    city { 'Paris' }
    zipcode { '75015' }
    code_uai { '075' + rand(10_000).to_s.rjust(5, '0') + ('a'..'z').to_a.sample }
    department { Department.find_by(code: '75') }
    rep_kind { '' }
    qpv { false }
    signature {Rack::Test::UploadedFile.new('test/fixtures/files/signature.png', 'image/png')}

    is_public { true }
    contract_code { '99' }
    legal_status { 'Public' }
    school_type { 'lycee' }

    trait :at_paris do
      city { 'Paris' }
      name { 'Parisian school' }
      coordinates { Coordinates.paris }
    end

    trait :without_signature do
      signature { nil }
    end

    trait :at_bordeaux do
      city { 'bordeaux' }
      name { 'bordeaux school' }
      coordinates { Coordinates.bordeaux }
      zipcode { '33072' }
      department { Department.find_by(code: '33') }
    end

    trait :with_weeks do
      weeks { Week.selectable_on_school_year[0..1] }
    end

    trait :with_school_manager do
      after(:create) do |school|
        create(:school_manager, school: school)
      end
    end

    trait :lycee do
      school_type { :lycee }
    end

    trait :college do
      school_type { :college }
    end
  end

  factory :api_school, class: Api::School do
    name { 'Lycée evariste Gallois' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    zipcode { '75015' }
  end
end
