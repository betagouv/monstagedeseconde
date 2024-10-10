FactoryBot.define do
  factory :grade do
    name { 'MyString' }
    short_name { 'MyString' }
    trait :troisieme do
      name { 'Troisième générale' }
      short_name { 'troisieme' }
      school_year_end_day { 31 }
      school_year_end_month { 5 }
    end
    trait :quatrieme do
      name { 'Quatrième générale' }
      short_name { 'quatrieme' }
      school_year_end_day { 31 }
      school_year_end_month { 5 }
    end
    trait :seconde do
      name { 'Seconde générale et technologique' }
      short_name { 'seconde' }
      school_year_end_day { 30 }
      school_year_end_month { 6 }
    end
  end
end
