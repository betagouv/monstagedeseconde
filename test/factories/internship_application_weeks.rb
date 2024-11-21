FactoryBot.define do
  factory :internship_application_week do
    week # { Week.selectable_from_now_until_end_of_school_year.sample }
    internship_application
  end
end
