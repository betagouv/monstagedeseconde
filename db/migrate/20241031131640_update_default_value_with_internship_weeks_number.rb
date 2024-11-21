class UpdateDefaultValueWithInternshipWeeksNumber < ActiveRecord::Migration[7.1]
  def change
    change_column_default :internship_offers, :internship_weeks_number, from: 0, to: 1
    change_column_default :internship_offers, :max_candidates, from: 0, to: 1
    change_column_default :internship_offers, :max_students_per_group, from: 0, to: 1

    change_column_default :plannings, :internship_weeks_number, from: 0, to: 1
    change_column_default :plannings, :max_candidates, from: 0, to: 1
    change_column_default :plannings, :max_students_per_group, from: 0, to: 1
  end
end
