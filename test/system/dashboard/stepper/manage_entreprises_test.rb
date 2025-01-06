# frozen_string_literal: true

require 'application_system_test_case'

class ManageEntreprisesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include EntrepriseFormFiller

  test 'can create Entreprise' do
    internship_occupation = create(:internship_occupation)
    sector                = create(:sector, name: 'Architecture')
    group                 = create(:group, is_public: true, name: "Ministère de l'Amour")

    sign_in(internship_occupation.employer)
    visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
    fill_in_entreprise_form(group:, sector:)
    find("button[type='submit']").click
    find('#alert-success', text: "Les informations de l'entreprise ont bien été enregistrées")

    entreprise = Entreprise.last
    assert_equal 'Mairie de Saint-Ouen-l’Aumône', entreprise.employer_name
    assert_equal '21950572400209', entreprise.siret
    assert_equal group.id, entreprise.group_id
    assert entreprise.is_public
  end

  test 'fails gracefully when creating Entreprise with missing sector' do
    internship_occupation = create(:internship_occupation)
    group                 = create(:group, is_public: true, name: "Ministère de l'Amour")

    sign_in(internship_occupation.employer)
    visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
    fill_in_entreprise_form(group:, sector: nil)
    find("button[type='submit']").click
    assert_equal 0, Entreprise.all.count
    find(".fr-stepper__steps[data-fr-current-step='2'][data-fr-steps='3']")
  end

  test 'when manual creation of Entreprise ' do
    internship_occupation = create(:internship_occupation)
    sector                = create(:sector, name: 'Architecture')
    group                 = create(:group, is_public: true, name: "Ministère de l'Amour")

    sign_in(internship_occupation.employer)
    visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
    fill_in_entreprise_manual_form(group:, sector:)
    find('p.fr-card__desc[data-write-summary-card-target="employerNameOutput"]', text: 'Mairie de Saint-Ouen-l’Aumône')
    find("button[type='submit']").click
    find('#alert-success', text: "Les informations de l'entreprise ont bien été enregistrées")

    entreprise = Entreprise.last
    assert_equal 'Mairie de Saint-Ouen-l’Aumône', entreprise.employer_name
    assert_equal "PLACE PIERRE MENDES FRANCE 95310 SAINT-OUEN-L'AUMONE", entreprise.entreprise_full_address
    assert_equal '', entreprise.siret
    assert_equal group.id, entreprise.group_id
    assert entreprise.is_public
    assert entreprise.internship_address_manual_enter
    find('.fr-stepper__state', text: 'Étape 3 sur 3')

    find('a.fr-btn--secondary', text: 'Précédent').click
    assert_equal 'Mairie de Saint-Ouen-l’Aumône', entreprise.employer_name
    assert_equal "PLACE PIERRE MENDES FRANCE 95310 SAINT-OUEN-L'AUMONE", entreprise.entreprise_full_address

    click_button('Suivant')

    find('.fr-stepper__state', text: 'Étape 3 sur 3')
  end
end
