FactoryBot.define do
  factory :multi_corporation do
    multi_coordinator { association :multi_coordinator }
    after(:create) do |corp|
      create(:corporation, multi_corporation: corp, corporation_name: 'Darty lux')
      create(:corporation, multi_corporation: corp, corporation_name: 'Radio Electroménager')
      create(:corporation, multi_corporation: corp, corporation_name: 'Brain Dry Pump')
      create(:corporation, multi_corporation: corp, corporation_name: 'Leaders Connect')
      create(:corporation, multi_corporation: corp, corporation_name: 'Auto Plus Services')
    end
  end
end