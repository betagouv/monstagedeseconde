FactoryBot.define do
  factory :multi_corporation do
    multi_coordinator { association :multi_coordinator }
    after(:create) do |corp|
      create(:corporation, multi_corporation: corp, employer_name: 'Darty lux')
      create(:corporation, multi_corporation: corp, employer_name: 'Radio Electroménager')
      create(:corporation, multi_corporation: corp, employer_name: 'Brain Dry Pump')
      create(:corporation, multi_corporation: corp, employer_name: 'Leaders Connect')
      create(:corporation, multi_corporation: corp, employer_name: 'Auto Plus Services')
    end
  end
end