require 'application_system_test_case'

class ManageCompleteOfferFillingTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include OrganisationFormFiller
  include InternshipOfferInfoFormFiller
  include PracticalInfoFormFiller

  def wait_form_submitted
    find('.alert-sticky')
  end

  test 'can create a public sector offer' do
    2.times { create(:school) }
    employer = create(:employer)
    group    = create(:group, name: 'hello', is_public: true)
    new_group_name = "Ministère de l'Amour"
    group_amour = create(:group, name: new_group_name, is_public: true)
    sector = create(:sector)
    travel_to(Date.new(2024, 3, 1)) do
      sign_in(employer)
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      # Step 1
      fill_in_public_organisation_form(group:)
      click_on 'Suivant'
      find('legend', text: 'Description du stage')
      # Step 2
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 5')
      fill_in_internship_offer_info_form(sector:)
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 3 sur 5')
      click_on 'Suivant'
      fill_in_practical_infos_form
      click_on 'Suivant'
      find('span#alert-text', text: 'Votre offre de stage est prête à être publiée')
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 5 sur 5')
      click_on 'Modifier'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 4 sur 5')
      click_on 'Précédent'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 3 sur 5')
      click_on 'Précédent'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 5')
      click_on 'Précédent'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 1 sur 5')
      select new_group_name
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 5')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 3 sur 5')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 4 sur 5')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 5 sur 5')
      find("button.fr-btn[type='submit']", text: 'Publier').click
      wait_form_submitted
      find('span#alert-text', text: 'Votre annonce a bien été publiée')
      offer = InternshipOffer.last
      all("tbody tr.test-internship-offer-#{offer.id} td").first do
        find('p.internship-item-title', text: offer.title)
      end
    end
    internship_offer = InternshipOffer.last
    assert_equal 'EAST SIDE SOFTWARE', internship_offer.employer_name
    assert_equal group_amour.id, internship_offer.group_id
    assert_equal group_amour.id, internship_offer.organisation.group_id
  end
  test 'can create navigate back and forth while creating a private sector offer' do
    2.times { create(:school) }
    employer = create(:employer)
    group    = create(:group, name: 'hello', is_public: false)
    sector   = create(:sector)
    travel_to(Date.new(2024, 3, 1)) do
      sign_in(employer)
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      # Step 1
      fill_in_organisation_form(is_public: false, group:)
      click_on 'Suivant'
      find('legend', text: 'Description du stage')
      # Step 2
      click_link 'Précédent'
      # Back to step 1
      find('legend', text: "Présentation de l'entreprise")
      click_on 'Suivant'
      # Step 2
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 5')
      fill_in_internship_offer_info_form(sector:)
      click_on 'Suivant'
      # Step 3
      click_on 'Précédent'
      # Step 2
      # find('legend', text: 'Offre de stage')
      click_on 'Précédent'
      # Step 1
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 1 sur 5')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 2 sur 5')
      click_on 'Suivant'
      find('h2.fr-stepper__title span.fr-stepper__state', text: 'Étape 3 sur 5')
      click_on 'Suivant'
      fill_in_practical_infos_form
      click_on 'Suivant'
      find('span#alert-text', text: 'Votre offre de stage est prête à être publiée')
      find("button.fr-btn[type='submit']", text: 'Publier').click
      wait_form_submitted
      find('span#alert-text', text: 'Votre annonce a bien été publiée')
      offer = InternshipOffer.last
      all("tbody tr.test-internship-offer-#{offer.id} td").first do
        find('p.internship-item-title', text: offer.title)
      end
    end
  end

  test 'logged in employer accesses her idle offer through email url (cta)' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer:)
    travel_to(Date.new(2024, 3, 1)) do
      sign_in(employer)
      visit internship_offer_path(id: internship_offer.id, mtm_campaign: 'Offreur_Offre_de_stage_en_attente',
                                  origine: 'email')
      assert_equal internship_offer.title, find('h1').text
      assert_equal '1 rue du poulet 75001 Paris', find('.row .col-12 .fr-pl-1w.blue-france').text
    end
  end

  test 'unconnected employer accesses her idle offer through email url (cta) and logging' do
    password = '45po78M;$pass'
    employer = create(:employer, password:)
    internship_offer = create(:weekly_internship_offer, employer:)
    travel_to(Date.new(2024, 3, 1)) do
      visit internship_offer_path(id: internship_offer.id, mtm_campaign: 'Offreur_Offre_de_stage_en_attente',
                                  origine: 'email')
      assert_equal 'Connexion à Mon stage de seconde', find('h1').text
      fill_in 'Adresse électronique', with: employer.email
      fill_in 'Mot de passe', with: password
      click_on 'Se connecter'
      assert_equal internship_offer.title, find('h1').text
      assert_equal '1 rue du poulet 75001 Paris', find('.row .col-12 .fr-pl-1w.blue-france').text
    end
  end
end
