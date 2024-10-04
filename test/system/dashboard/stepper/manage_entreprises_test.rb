# frozen_string_literal: true

require 'application_system_test_case'

class ManageEntreprisesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include EntrepriseFormFiller

  test 'can create Entreprise' do
    internship_occupation = create(:internship_occupation)
    employer              = create(:employer)
    sector                = create(:sector, name: 'Architecture')
    group                 = create(:group, is_public: true, name: "Ministère de l'Amour")

    sign_in(employer)
    visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
    fill_in_entreprise_form(group:, sector:)
    find("button[type='submit']").click
    find('#alert-success', text: "Les informations de l'entreprise ont bien été enregistrées")

    entreprise = Entreprise.last
    assert_equal 'East Side Software-Paris', entreprise.employer_name
    assert_equal '90943224700015', entreprise.siret
    assert_equal group.id, entreprise.group_id
    assert entreprise.is_public
  end
  test 'can create Entreprise with tutor details' do
    internship_occupation = create(:internship_occupation)
    employer              = create(:employer)
    sector                = create(:sector, name: 'Architecture')
    group                 = create(:group, is_public: true, name: "Ministère de l'Amour")

    sign_in(employer)
    visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
    fill_in_entreprise_form(group:, sector:)
    fill_in 'Prénom du référent', with: 'Jean'
    fill_in 'Nom du référent', with: 'Dupont'
    fill_in 'Fonction du référent', with: 'Directeur'
    fill_in 'Numéro de téléphone du référent', with: '0123456789'
    fill_in 'Adresse électronique du référent', with: 'test@free.fr'
    find("button[type='submit']").click
    find('#alert-success', text: "Les informations de l'entreprise ont bien été enregistrées")

    entreprise = Entreprise.last
    assert_equal 'East Side Software-Paris', entreprise.employer_name
    assert_equal '90943224700015', entreprise.siret
    assert_equal group.id, entreprise.group_id
    assert_equal 'Jean', entreprise.tutor_first_name
    assert_equal 'Dupont', entreprise.tutor_last_name
    assert_equal 'Directeur', entreprise.tutor_function
    assert_equal '0123456789', entreprise.tutor_phone
    assert_equal 'test@free.fr', entreprise.tutor_email
    assert entreprise.is_public
  end

  test 'fails gracefully when creating Entreprise with faulty tutor details' do
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
