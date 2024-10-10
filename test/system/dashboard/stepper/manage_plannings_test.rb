# frozen_string_literal: true

require 'application_system_test_case'

class ManagePlanningsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'can create a planning with grade troisieme ' do
    employer = create(:employer)
    entreprise = create(:entreprise)
    grade_2e = create(:grade, :seconde)
    grade_3e = create(:grade, :troisieme)
    grade_4e = create(:grade, :quatrieme)
    internship_occupation = entreprise.internship_occupation

    sign_in(employer)
    visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id,
                                              internship_occupation_id: internship_occupation.id)
    execute_script('document.getElementById("planning_grade_3e4e").click()')
    execute_script('document.getElementById("planning_all_year_long_true").click()')

    find("button[type='submit']").click
    notice = find('span#alert-text').text
    assert_match 'Votre offre est publiée', notice

    planning = Planning.last
    assert !!planning.id
    refute grade_2e.in?(planning.grades)
    assert grade_3e.in?(planning.grades)
    assert grade_4e.in?(planning.grades)
  end

  test 'fails gracefully when creating planning with faulty xxxxxxxxxxx' do
    internship_occupation = create(:internship_occupation)
    employer              = create(:employer)
    sector                = create(:sector, name: 'Architecture')
    group                 = create(:group, is_public: true, name: "Ministère de l'Amour")

    sign_in(employer)
    visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
    fill_in_entreprise_form(group:, sector:)
    fill_in 'Prénom du référent', with: 'J' # too short
    fill_in 'Nom du référent', with: 'Dupont'
    fill_in 'Fonction du référent', with: 'Directeur'
    fill_in 'Numéro de téléphone du référent', with: '0123456789'
    fill_in 'Adresse électronique du référent', with: 'test@free.fr'
    find("button[type='submit']").click
    text = find('.fr-alert.fr-alert--error').text
    assert text.match?(/trop court/)
    assert_equal 0, Entreprise.all.count
  end
end
