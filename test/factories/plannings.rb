FactoryBot.define do
  factory :planning do
    entreprise
    max_candidates { 1 }
    max_students_per_group { 1 }
    weekly_hours { ['08:00', '15:00'] }
    daily_hours do
      { 'jeudi' => ['08:00', '15:00'],
        'lundi' => ['08:00', '15:00'],
        'mardi' => ['08:00', '15:00'],
        'samedi' => ['08:00', '15:00'],
        'mercredi' => ['08:00', '15:00'],
        'vendredi' => ['08:00', '15:00'] }
    end
    employer_id { entreprise.internship_occupation.employer_id }
    lunch_break { ' test de lunch break' }
    weeks { Week.both_school_track_selectable_weeks }
    grades { Grade.all }

    trait :with_seconde_only do
      weeks { SchoolTrack::Seconde.both_weeks }
      grades { [Grade.seconde] }
    end

    trait :with_troisieme_only do
      weeks { Week.troisieme_selectable_weeks }
      grades { [Grade.troisieme] }
    end

    trait :with_seconde_and_troisieme do
      # default
    end

  end
end
