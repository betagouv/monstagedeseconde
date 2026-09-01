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

  # Stage partagé : exactement 2 structures d'accueil, une par période (1 semaine chacune).
  factory :shared_multi_corporation, class: 'MultiCorporation' do
    multi_coordinator { association :multi_coordinator }
    after(:create) do |corp|
      create(:corporation, multi_corporation: corp, corporation_name: 'Darty lux', period: 1)
      create(:corporation, multi_corporation: corp, corporation_name: 'Radio Electroménager', period: 2)
    end
  end
end