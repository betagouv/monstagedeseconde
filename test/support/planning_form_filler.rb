module PlanningFormFiller
  def fill_in_planning_form(with_troisieme: true, with_seconde: true, all_year_long: true)
    # default values are all checked
    execute_script('document.getElementById("planning_grade_3e4e").click()') unless with_troisieme
    execute_script('document.getElementById("planning_all_year_long_true").click()') unless all_year_long
    execute_script('document.getElementById("planning_grade_2e").click()') unless with_seconde

    fill_in "Nombre total d'élèves que vous souhaitez accueillir sur la période de stage", with: 10
    find('#planning_weekly_hours_start').select('08:00')
    find('#planning_weekly_hours_end').select('15:00')
    fill_in 'Pause déjeuner', with: 'test de lunch break'
  end
end
