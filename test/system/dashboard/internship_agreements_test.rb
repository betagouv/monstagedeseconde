require 'application_system_test_case'

module Dashboard
  class InternshipAgreementTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test 'employer reads internship agreement list and read his own agreements with student having a school with a school manager' do
      employer = create(:employer)
      employer_2 = create(:employer)

      student = create(:student, school: create(:school))
      refute student.school.school_manager.present?

      internship_offer = create(:weekly_internship_offer_2nde, employer:)
      internship_offer_2 = create(:weekly_internship_offer_2nde, employer: employer_2)
      internship_application = create(
        :weekly_internship_application,
        internship_offer:,
        student:
      )
      internship_application_2 = create(:weekly_internship_application, internship_offer: internship_offer_2)
      create(:internship_agreement, aasm_state: :draft, internship_application:)
      create(:internship_agreement, aasm_state: :draft, internship_application: internship_application_2)

      sign_in(employer)
      visit dashboard_internship_agreements_path

      # assert all('td[data-head="Statut"]').empty?
    end

    test 'school_manager reads internship agreement list and read his own agreements' do
      school = create(:school, :with_school_manager)
      school_2 = create(:school)
      student = create(:student, school:)
      student_2 = create(:student, school: school_2)
      internship_offer = create(:weekly_internship_offer_2nde)
      internship_application = create(:weekly_internship_application, internship_offer:,
                                                                      student:)
      internship_application_2 = create(:weekly_internship_application, internship_offer:,
                                                                        student: student_2)
      create(:internship_agreement, aasm_state: :draft, internship_application:)
      create(:internship_agreement, aasm_state: :draft, internship_application: internship_application_2)
      sign_in(school.school_manager)
      visit dashboard_internship_agreements_path

      within('td[data-head="Statut"]') do
        assert_equal 1, all('div.actions').count
      end
    end

    test 'employer reads internship agreement table with correct indications - draft' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :draft)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'À remplir par les deux parties.')
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: started_by_employer' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :started_by_employer)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention').click
      fill_in "Fonction du représentant de l'entreprise", with: 'CEO'
      fill_in "Adresse email du responsable de l'accueil en milieu professionnel", with: 'tuteur@free.fr'
      select('08:00', from: 'internship_agreement_weekly_hours_start')
      select('16:00', from: 'internship_agreement_weekly_hours_end')
      fill_in('Pause déjeuner', with: "un repas à la cantine d'entreprise")
      click_button('Valider la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: 'Valider la convention')
    end

    test 'employer reads internship agreement table with correct indications / daily hours - status: started_by_employer' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :started_by_employer)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention').click
      find("input[name='internship_agreement[organisation_representative_full_name]']")
      fill_in "Fonction du représentant de l'entreprise", with: 'CEO'
      fill_in "Adresse email du responsable de l'accueil en milieu professionnel", with: 'tuteur@free.fr'
      fill_in "Nom de l'entreprise", with: 'Corporation'
      fill_in 'Adresse email de contact', with: 'corp@mail.com'
      fill_in 'Adresse du lieu du stage', with: '1 rue de la paix'
      find('label', text: 'Les horaires seront les mêmes sur toute la période de stage')
      execute_script("document.getElementById('weekly_planning').checked = false;")
      execute_script("document.getElementById('daily-planning-container').classList.remove('d-none');")
      select('08:00', from: 'internship_agreement_daily_hours_lundi_start')
      select('16:00', from: 'internship_agreement_daily_hours_lundi_end')
      select('08:00', from: 'internship_agreement_daily_hours_mardi_start')
      select('16:00', from: 'internship_agreement_daily_hours_mardi_end')
      select('08:00', from: 'internship_agreement_daily_hours_mercredi_start')
      select('16:00', from: 'internship_agreement_daily_hours_mercredi_end')
      select('08:00', from: 'internship_agreement_daily_hours_jeudi_start')
      select('16:00', from: 'internship_agreement_daily_hours_jeudi_end')
      select('08:00', from: 'internship_agreement_daily_hours_vendredi_start')
      select('16:00', from: 'internship_agreement_daily_hours_vendredi_end')
      text_area = first(:css,
                        "textarea[name='internship_agreement[lunch_break]']").native.send_keys('un repas à la cantine bien chaud')
      # samedi is avoided on purpose
      click_button('Valider la convention')
      find("button[data-action='click->internship-agreement-form#completeByEmployer']", text: 'Valider la convention')
      find("button[data-action='click->internship-agreement-form#completeByEmployer']",
           text: 'Valider la convention').click
      # find('h1', text: "truc", wait: 3.seconds)
      # assert_in_delta internship_agreement.updated_at, Time.now, 1
      find('span#alert-text', text: "La convention a été envoyée au chef d'établissement.")
      find('h1.h4.fr-mb-8w.text-dark', text: 'Editer, imprimer et signer les conventions dématérialisées')

      expected_days_hours = {
        'lundi' => ['08:00', '16:00'],
        'mardi' => ['08:00', '16:00'],
        'mercredi' => ['08:00', '16:00'],
        'jeudi' => ['08:00', '16:00'],
        'vendredi' => ['08:00', '16:00'],
        'samedi' => ['', '']
      }
      assert_equal expected_days_hours, internship_agreement.reload.daily_hours
    end

    test 'employer reads internship agreement table with missing indications / daily hours - status: started_by_employer' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :started_by_employer, weekly_hours: [])
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention').click
      find("input[name='internship_agreement[organisation_representative_full_name]']")
      fill_in "Fonction du représentant de l'entreprise", with: 'CEO'
      fill_in "Nom de l'entreprise", with: 'Corporation'
      fill_in 'Adresse email de contact', with: 'corp@mail.com'
      fill_in 'Adresse du lieu du stage', with: '1 rue de la paix'
      fill_in "Adresse email du responsable de l'accueil en milieu professionnel", with: 'tuteur@free.fr'
      execute_script("document.getElementById('weekly_planning').checked = false;")
      execute_script("document.getElementById('daily-planning-container').classList.remove('d-none');")
      select('08:00', from: 'internship_agreement_daily_hours_lundi_start')
      select('16:00', from: 'internship_agreement_daily_hours_lundi_end')
      select('08:00', from: 'internship_agreement_daily_hours_mardi_start')
      select('16:00', from: 'internship_agreement_daily_hours_mardi_end')
      select('08:00', from: 'internship_agreement_daily_hours_mercredi_start')
      select('16:00', from: 'internship_agreement_daily_hours_mercredi_end')
      text_area = first(:css,
                        "textarea[name='internship_agreement[lunch_break]']").native.send_keys('un repas à la cantine bien chaud')
      # Missing lunch break indications on thursday and friday
      # samedi is avoided on purpose
      click_button('Valider la convention')
      find("button[data-action='click->internship-agreement-form#completeByEmployer']", text: 'Valider la convention')
      find("button[data-action='click->internship-agreement-form#completeByEmployer']",
           text: 'Valider la convention').click
      alert_text = all('.fr-alert.fr-alert--error').first.text
      assert_equal alert_text, 'Planning hebdomadaire : Veuillez compléter les horaires et repas de la semaine de stage'
    end

    test 'employer reads internship agreement table with correct indications - status: completed_by_employer /' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :completed_by_employer)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions',
             text: "La convention doit être remplie par l'établissement. Vous pouvez cependant l'imprimer en attendant son remplissage.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
    end

    test 'employer reads internship agreement table with correct indications - status: started_by_school_manager' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :started_by_school_manager)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions',
             text: "La convention doit être remplie par l'établissement. Vous pouvez cependant l'imprimer en attendant son remplissage.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
    end

    test 'employer reads internship agreement table with correct indications - status: validated' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :validated)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est prête à être signée.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads internship agreement table with correct indications - status: signatures_started with employer' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :signatures_started)
      create(:signature, internship_agreement:, signatory_role: :employer,
                         user_id: internship_agreement.employer.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Vous avez déjà signé. En attente de la signature du chef d’établissement.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'employer reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :signatures_started)
      create(:signature, internship_agreement:, signatory_role: :school_manager,
                         user_id: internship_agreement.school_manager.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Le chef d'établissement a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads internship agreement table with correct indications - status: signed_by_all' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :signed_by_all)
      create(:signature, internship_agreement:, signatory_role: :school_manager,
                         user_id: internship_agreement.school_manager.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Signée par toutes les parties.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end

    # =================== School Manager ===================

    test 'school_manager reads internship agreement table with correct indications - draft' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, internship_application:,
                                                           aasm_state: :draft)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      find('a.button-component-cta-button', text: 'Remplir ma convention').click
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie par l'offreur, mais vous ne l'avez pas renseignée.")
      end
      fill_in 'Date de délibération du Conseil d’administration approuvant la convention-type', with: '10/10/2020'
      select('Privé sous contrat', from: 'Statut de l’établissement')
      click_button('Valider la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: 'Valider la convention')
      click_button('Je valide la convention')
      find('span#alert-text',
           text: 'La convention est validée, le fichier pdf de la convention est maintenant disponible.')
    end

    test 'school_manager reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est remplie, mais pas validée.')
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'school_manager reads internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est prête.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement:, signatory_role: :employer,
                         user_id: internship_agreement.employer.id)
      sign_in(internship_agreement.school_manager.reload)
      visit dashboard_internship_agreements_path

      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "L'employeur a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement:, signatory_role: :school_manager,
                         user_id: internship_agreement.school_manager.id)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Vous avez déjà signé. En attente de la signature de l’employeur.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Signée par toutes les parties.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end

    # =================== Admin Officer ===================

    test 'admin_officer reads internship agreement table with correct indications - draft' do
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: completed_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      find('a.button-component-cta-button', text: 'Remplir ma convention').click
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie par l'offreur, mais vous ne l'avez pas renseignée.")
      end
      fill_in 'Date de délibération du Conseil d’administration approuvant la convention-type', with: '10/10/2020'
      select('Privé hors contrat', from: 'Statut de l’établissement')
      click_button('Valider la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: 'Valider la convention')
      click_button('Je valide la convention')
      find('span#alert-text',
           text: 'La convention est validée, le fichier pdf de la convention est maintenant disponible.')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est remplie, mais pas validée.')
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est prête.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement:, signatory_role: :employer,
                         user_id: internship_agreement.employer.id)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "L'employeur a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement:, signatory_role: :school_manager,
                         user_id: internship_agreement.school_manager.id)
      admin_officer = create(:admin_officer, school: internship_agreement.school)
      assert Signature.first.signatory_role == 'school_manager'
      sign_in(admin_officer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex',
             text: "Le chef d'établissement a déjà signé. En attente de la signature de l’employeur.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'admin_officer reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Signée par toutes les parties.')
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end

    # =================== Statistician ===================

    test 'statistician without rights attempt to reach internship agreement table fails' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: false))
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      find('span#alert-text', text: "Vous n'êtes pas autorisé à effectuer cette action.")
    end

    test 'statistician reads internship agreement table with correct indications - draft' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :draft,
                                                           internship_application:)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('div.actions', text: 'À remplir par les deux parties.')
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'statistician reads internship agreement table with correct indications - status: started_by_employer' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer,
                                                           internship_application:)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'statistician reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer,
                                                           internship_application:)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
    end

    test 'statistician reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager,
                                                           internship_application:)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
    end

    test 'statistician reads internship agreement table with correct indications - status: validated' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :validated,
                                                           internship_application:)
      sign_in(internship_offer.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('div.actions', text: "Votre convention est prête à être signée.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'statistician reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      employer = internship_offer.employer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started,
                                                           internship_application:)
      create(:signature, internship_agreement:, signatory_role: :employer,
                         user_id: internship_agreement.employer.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature du chef d’établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'statistician reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      employer = internship_offer.employer
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started,
                                                           internship_application:)
      school_manager = internship_agreement.internship_application.student.school.school_manager
      create(:signature, internship_agreement:, signatory_role: :school_manager,
                         user_id: school_manager.id)
      sign_in(employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('.actions.d-flex', text: "Le chef d'établissement a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'statistician reads internship agreement table with correct indications - status: signed_by_all' do
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer: create(:statistician, agreement_signatorable: true))
      employer = internship_offer.employer
      employer.update(current_area_id: internship_offer.internship_offer_area.id)
      assert_equal employer.current_area, internship_offer.internship_offer_area
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all,
                                                           internship_application:)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        # find('.actions.d-flex', text: "Signée par toutes les parties.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end
  end
end
