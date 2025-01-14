module PlanningFormFiller
  def fill_in_planning_form(with_troisieme: true, with_seconde: true, all_year_long: true, max_candidates: 10, first_week: false, second_week: false, both_weeks: true)
    # default values are all checked
    execute_script('document.getElementById("planning_grade_college").click()') unless with_troisieme
    execute_script('document.getElementById("planning_all_year_long_true").click()') unless all_year_long
    execute_script('document.getElementById("planning_grade_2e").click()') unless with_seconde

    #TODO update weeks automatically
    legend = "Sur quelle période proposez-vous ce stage pour les lycéens ?"
    # order matters
    find("label[for='period_field_full_time']").click if both_weeks
    find("label[for='period_field_week_1']").click if first_week
    find("label[for='period_field_week_2']").click if second_week

    fill_in "Nombre total d'élèves que vous souhaitez accueillir sur la période de stage", with: max_candidates
    find('#planning_weekly_hours_start').select('08:00')
    find('#planning_weekly_hours_end').select('15:00')
    fill_in 'Pause déjeuner', with: 'test de lunch break'
  end
end
