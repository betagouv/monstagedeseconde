require 'application_system_test_case'

class ManageCompleteOfferFillingTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOccupationFormFiller
  include EntrepriseFormFiller
  include PlanningFormFiller

  def wait_form_submitted
    find('.alert-sticky')
  end

  test 'can create a complete offer' do
    skip 'test is relevant and shall pass by november 2024'
    group = create(:group, name: 'group example', is_public: true)
    sector = create(:sector, name: 'Ministère de l\'Amour')
    employer = create(:employer)
    sign_in(employer)
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2024, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_internship_occupation_form
        find('li#downshift-0-item-0', wait: 8).click
        find('span', text: 'Étape 1 sur 3')
        click_on 'Suivant'
        find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 3')
        fill_in_entreprise_form(group:, sector:)
        find("button[type='submit']").click
        find('span#alert-text', text: "Les informations de l'entreprise ont bien été enregistrées")
        find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 3 sur 3')
        fill_in_planning_form(with_seconde: false)
        execute_script('document.querySelector("input[name=\'is_reserved\']").click()')
        assert_difference('Planning.count') do
          assert_difference('InternshipOffers::WeeklyFramed.count') do
            find("button[type='submit']").click
            notice = find('span#alert-text').text
            assert_match 'Votre offre est publiée', notice
          end
        end
      end
    end
  end

  test 'can go backwards from planning to internhip_occupation' do
    skip 'test is relevant and shall pass by november 2024'
    group = create(:group, name: 'group example', is_public: true)
    sector = create(:sector, name: 'Ministère de l\'Amour')
    employer = create(:employer)

    sign_in(employer)
    travel_to(Date.new(2024, 3, 1)) do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_internship_occupation_form
      find('li#downshift-0-item-0', wait: 8).click
      find('span', text: 'Étape 1 sur 3')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 3')
      fill_in_entreprise_form(group:, sector:)
      find("button[type='submit']").click
      find('span#alert-text', text: "Les informations de l'entreprise ont bien été enregistrées")
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 3 sur 3')
      click_on 'Précédent'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 3')
      click_link 'Précédent'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 1 sur 3')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 3')
    end
  end
end
