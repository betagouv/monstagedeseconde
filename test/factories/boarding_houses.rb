# frozen_string_literal: true

FactoryBot.define do
  factory :boarding_house do
    name { 'Internat du Lycée Jean Moulin' }
    street { '12 rue de la Paix' }
    zipcode { '75001' }
    city { 'Paris' }
    contact_phone { '0123456789' }
    contact_email { 'internat@example.com' }
    coordinates { Coordinates.paris }
    available_places { 20 }
    reference_date { Date.new(2026, 6, 15) }
    academy { Department.fetch_by_zipcode(zipcode: '75001')&.academy || create(:academy) }
  end
end
