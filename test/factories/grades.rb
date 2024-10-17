FactoryBot.define do
  trait :default do
    name { 'Troisième générale' }
    short_name { 'troisieme' }
    school_year_end_day { 31 }
    school_year_end_month { 5 }
  end

  factory :grade do
    default

    trait :troisieme do
      default
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
