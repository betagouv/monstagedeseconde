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
    weeks { Week.selectable_from_now_until_end_of_school_year }
    grades { Grade.all }
    internship_weeks_number { 1 }
  end
end
