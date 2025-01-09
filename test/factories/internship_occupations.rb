FactoryBot.define do
  factory :internship_occupation do
    employer { create(:employer) }
    description { 'MyDescriptionText' }
    title { 'MyTtile' }
    street { '12 rue Taine' }
    zipcode { '75012' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    department { Department.lookup_by_zipcode(zipcode: zipcode) }
  end
end
