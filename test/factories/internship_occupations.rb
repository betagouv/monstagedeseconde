FactoryBot.define do
  factory :internship_occupation do
    employer_id { create(:employer).id }
    description { 'MyDescriptionText' }
    title { 'MyTtile' }
    street { '12 rue Taine' }
    zipcode { '75012' }
    city { 'Paris' }
    coordinates { Coordinates.pithiviers }
    internship_address_manual_enter { false }
  end
end
