class PopulateGrades < ActiveRecord::Migration[7.1]
  def up
    Grade.find_or_create_by!(short_name: :seconde, name: 'seconde générale et technologique',
                             school_year_end_month: '06', school_year_end_day: '30')
    Grade.find_or_create_by!(short_name: :troisieme, name: 'troisieme générale', school_year_end_month: '05',
                             school_year_end_day: '31')
    Grade.find_or_create_by!(short_name: :quatrieme, name: 'quatrieme générale et technologique',
                             school_year_end_month: '05', school_year_end_day: '31')
  end
end
