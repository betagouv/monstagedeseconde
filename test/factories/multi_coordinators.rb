# frozen_string_literal: true

FactoryBot.define do
  factory :multi_coordinator do
    siret { '66204244900014' }
    employer_name { 'BNP PARIBAS' }
    employer_chosen_name { 'BNP PARIBAS' }
    employer_address { '16 BOULEVARD DES ITALIENS 75009 PARIS' }
    employer_chosen_address { '16 BOULEVARD DES ITALIENS 75009 PARIS' }
    city { 'PARIS' }
    zipcode { '75009' }
    street { '16 BOULEVARD DES ITALIENS' }
    phone { '0653615361' }
    association :multi_activity
    association :sector
  end
end

