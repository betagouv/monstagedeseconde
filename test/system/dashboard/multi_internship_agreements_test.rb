require 'application_system_test_case'

module Dashboard
  class MultiInternshipAgreementTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper
    include ActionMailer::TestHelper

    def visit_index_and_go_to_multi_internship_agreements
      visit dashboard_internship_agreements_path
      click_on 'Conventions multi-offreurs'
    end

    def school_manager_visits_index_and_go_to_multi_internship_agreements
      visit dashboard_internship_agreements_path
      click_button 'Mes conventions de stage multi-offreurs'
    end

    def double_agreement_validation
      find("#send_agreement").click
      within(".fr-modal__footer") do
        click_button('Valider la convention')
      end
    end

    test 'employer reads multi internship agreement list and read his own agreements with student having a school with a school manager' do
      employer = create(:employer)
      employer_2 = create(:employer)

      student = create(:student, school: create(:school))
      refute student.school.school_manager.present?

      internship_offer = create(:multi_internship_offer, employer:)
      internship_offer_2 = create(:multi_internship_offer, employer: employer_2)
      internship_application = create(
        :weekly_internship_application,
        internship_offer:,
        student:
      )
      internship_application_2 = create(:weekly_internship_application, internship_offer: internship_offer_2)
      create(:multi_internship_agreement, aasm_state: :draft, internship_application:)
      create(:multi_internship_agreement, aasm_state: :draft, internship_application: internship_application_2)

      sign_in(employer)
      visit dashboard_internship_agreements_path

      # assert all('td[data-head="Statut"]').empty?
    end

    test 'employer reads multi internship agreement table with correct indications - draft' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      assert InternshipOffer.last.from_multi?
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :draft)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'À remplir par les deux parties.')
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'employer reads multi internship agreement table with correct indications - status: started_by_employer' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :started_by_employer)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention').click
      select('08:00', from: 'internship_agreements_multi_internship_agreement_weekly_hours_start')
      select('16:00', from: 'internship_agreements_multi_internship_agreement_weekly_hours_end')
      fill_in('Pause déjeuner', with: "un repas à la cantine d'entreprise")
      click_button('Valider la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: 'Valider la convention')
    end

    test 'employer reads multi internship agreement table with correct indications / daily hours - status: started_by_employer' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :started_by_employer)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention').click
      find('label', text: 'Les horaires seront les mêmes sur toute la période de stage')
      execute_script("document.getElementById('weekly_planning').checked = false;")
      execute_script("document.getElementById('daily-planning-container').classList.remove('d-none');")
      select('08:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_lundi_start')
      select('16:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_lundi_end')
      select('08:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_mardi_start')
      select('16:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_mardi_end')
      select('08:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_mercredi_start')
      select('16:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_mercredi_end')
      select('08:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_jeudi_start')
      select('16:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_jeudi_end')
      select('08:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_vendredi_start')
      select('16:00', from: 'internship_agreements_multi_internship_agreement_daily_hours_vendredi_end')

      # samedi is avoided on purpose
      text_area = first(:css,
                        "textarea[name='internship_agreements_multi_internship_agreement[lunch_break]']").native.send_keys('un repas à la cantine bien chaud')
      fill_in('Pause déjeuner', with: "un repas à la cantine d'entreprise")
      double_agreement_validation

      find('span#alert-text', text: "La convention a été envoyée au chef d'établissement.")
      find('h1.h4.fr-mb-4w.text-dark', text: 'Editer, imprimer et signer les conventions dématérialisées')

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

    # -- Helper methods for tests with multiple agreements

    def make_an_agreement
      internship_agreement = create(:multi_internship_agreement)
      corporation = internship_agreement.internship_offer.corporations.first
      corporation_sgid = corporation.to_sgid.to_s
      [internship_agreement, corporation, corporation_sgid]
    end

    def make_a_validated_agreement
      internship_agreement = create(:multi_internship_agreement, :validated)
      corporation = internship_agreement.internship_offer.corporations.first
      corporation_sgid = corporation.to_sgid.to_s
      [internship_agreement, corporation, corporation_sgid]
    end

    def create_agreement_on_same_corporation(internship_agreement:)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_agreement.internship_offer)
      internship_agreement2 = internship_application.internship_agreement
    end

    def agreement_checkbox_id(internship_agreement)
      "corporation_internship_agreement_internship_agreement_id_#{internship_agreement.id}_checkbox"
    end

    def add_button(internship_agreement)
      find("button[data-group-signing-id-param='#{internship_agreement.id}']")
    end

    def general_cta_button
      find("button[data-group-signing-target='generalCta']")
    end

    def general_checkbox
      find("input[data-group-signing-target='generalCtaSelectBox']", visible: false)
    end

    # -- end of helper methods

    test 'signator responsible multi validates internship agreement' do
      internship_agreement, corporation, corporation_sgid = make_a_validated_agreement
      internship_agreement2 = create_agreement_on_same_corporation(internship_agreement: internship_agreement)

      sign_in(internship_agreement.employer)
      visit_index_and_go_to_multi_internship_agreements
      assert_text "Offreurs (0/5)"
      sign_out(internship_agreement.employer)

      # mails are sent when clicking on GeneralCta button, but this is not in the test

      visit dashboard_corporation_internship_agreements_path(corporation_sgid: corporation_sgid)

      assert_text "vous avez 2 conventions de stage à signer"

      assert general_cta_button.disabled?
      add_button(internship_agreement).click
      refute general_cta_button.disabled?

      general_checkbox
      refute general_checkbox.checked?

      add_button(internship_agreement2).click
      assert general_checkbox.checked?

      general_cta_button.click

      assert_text "vous n'avez aucune convention de stage à signer"

      sign_in(internship_agreement.employer)
      visit_index_and_go_to_multi_internship_agreements
      assert_text "Offreurs (1/5)"
    end

    test 'signator responsible multi validates one internship agreement' do
      internship_agreement, corporation, corporation_sgid = make_an_agreement
      internship_agreement2 = create_agreement_on_same_corporation(internship_agreement: internship_agreement)

      visit dashboard_corporation_internship_agreements_path(corporation_sgid: corporation_sgid)

      assert_text "vous avez 2 conventions de stage à signer"

      add_button(internship_agreement).click
      refute general_cta_button.disabled?

      general_cta_button.click

      assert_text "vous avez une convention de stage à signer"
      assert_equal 1, CorporationInternshipAgreement.signed.count

      add_button(internship_agreement2).click
      assert general_checkbox.checked?
    end

    test 'employer reads multi internship agreement table with correct indications - status: completed_by_employer /' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :completed_by_employer)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions',
             text: "La convention doit être remplie par l'établissement. Vous pouvez cependant l'imprimer en attendant son remplissage.")
      end
      find('a.button-component-cta-button', text: 'Télécharger')
    end

    test 'employer reads multi internship agreement table with correct indications - status: started_by_school_manager' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :started_by_school_manager)
      sign_in(internship_offer.employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions',
             text: "La convention doit être remplie par l'établissement. Vous pouvez cependant l'imprimer en attendant son remplissage.")
      end
      find('a.button-component-cta-button', text: 'Télécharger')
    end

    test 'employer reads multi internship agreement table with correct indications - status: validated' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :validated)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est prête à être signée.')
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      # find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads multi internship agreement table with correct indications - status: signatures_started with school_manager' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :signatures_started)
      create(:signature,
             :school_manager,
             internship_agreement:,
             user_id: internship_agreement.school_manager.id)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      # find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads multi internship agreement table with correct indications - status: signed_by_all' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :signed_by_all)
      create(:signature,
             :school_manager,
             internship_agreement:,
             user_id: internship_agreement.school_manager.id)
      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Signée par toutes les parties.')
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      find('a.fr-btn', text: 'Signée de tous')
    end

    test 'multi internship_agreements employer checks the corporation signature status modal' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :validated)
      employer = internship_agreement.employer
      first_corporation = internship_agreement.internship_offer.corporations.first
      multi_corporation = internship_agreement.multi_corporation
      corporation_internship_agreement = internship_agreement.corporation_internship_agreements.find_by(corporation: first_corporation, internship_agreement: internship_agreement)
      corporation_internship_agreement.update( signed: true )
      multi_corporation.update!(signatures_launched_at: Time.current)
      assert internship_agreement.internship_offer.multi_corporation.corporations.ids.include?(first_corporation.id)
      refute_nil first_corporation.multi_corporation.signatures_launched_at

      sign_in(employer)
      visit_index_and_go_to_multi_internship_agreements
      click_on 'Statut des signatures'
      assert_emails 4 do
        click_on "Envoyer un rappel"
      end
      click_on "Conventions multi-offreurs"
      assert_text "Offreurs (1/5)"
    end

    # =================== School Manager ===================
    test 'school_manager reads multi internship agreement list and read his own agreements' do
      school = create(:school, :with_school_manager)
      student = create(:student, school:)
      school_2 = create(:school, :college)
      student_2 = create(:student, school: school_2)
      employer, internship_offer = create_employer_and_multi_offer_3eme
      internship_application = create(:weekly_internship_application, internship_offer:,
                                                                      student:)
      internship_application_2 = create(:weekly_internship_application, internship_offer:,
                                                                        student: student_2)
      create(:multi_internship_agreement, aasm_state: :draft, internship_application:)
      create(:multi_internship_agreement, aasm_state: :draft, internship_application: internship_application_2)
      sign_in(school.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements

      within('td[data-head="Statut"]') do
        assert_equal 1, all('div.actions').count
      end
    end

    test 'school_manager reads multi internship agreement table with correct indications - draft' do
      employer, internship_offer = create_employer_and_multi_offer_2de
      internship_application = create(:weekly_internship_application, internship_offer:)
      internship_agreement = create(:multi_internship_agreement, internship_application:,
                                                           aasm_state: :draft)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads multi internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :started_by_employer)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads multi internship agreement table with correct indications - status: completed_by_employer /' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :completed_by_employer)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      find('a.button-component-cta-button', text: 'Remplir ma convention').click
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie par l'offreur, mais vous ne l'avez pas renseignée.")
      end
      fill_in 'Date de délibération du Conseil d’administration approuvant la convention-type (optionnel)', with: '10/10/2020'
      select('Privé sous contrat', from: 'Statut de l’établissement')
      click_button('Valider la convention')
      find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: 'Valider la convention')
      click_button('Je valide la convention')
      find('span#alert-text',
           text: 'La convention est validée, le fichier pdf de la convention est maintenant disponible.')
    end

    test 'school_manager reads multi internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :started_by_school_manager)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est remplie, mais pas validée.')
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'school_manager reads multi internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :validated)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'Votre convention est prête.')
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      # find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads multi internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :signatures_started)
      create(:signature,
             :employer,
             internship_agreement:,
             user_id: internship_agreement.employer.id)
      sign_in(internship_agreement.school_manager.reload)
      school_manager_visits_index_and_go_to_multi_internship_agreements

      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "L'employeur a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      # find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads multi internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :signatures_started)
      create(:signature,
             :school_manager,
             internship_agreement:,
             user_id: internship_agreement.school_manager.id)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Vous avez déjà signé. En attente de la signature de l’employeur.')
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      find('div[style="color: green"] span', text: 'établissement'.capitalize)
    end

    test 'school_manager reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:multi_internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.school_manager)
      school_manager_visits_index_and_go_to_multi_internship_agreements
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: 'Signée par toutes les parties.')
      end
      find('a.button-component-cta-button', text: 'Télécharger')
      find('a.fr-btn', text: 'Signée de tous')
    end

    # =================== Admin Officer ===================

    # test 'admin_officer reads multi internship agreement table with correct indications - draft' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :draft)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('div.actions', text: 'En attente de l\'offreur.')
    #   end
    #   find('a.button-component-cta-button', text: 'En attente')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: started_by_employer' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :started_by_employer)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('div.actions', text: 'En attente de l\'offreur.')
    #   end
    #   find('a.button-component-cta-button', text: 'En attente')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: completed_by_employer' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :completed_by_employer)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   find('a.button-component-cta-button', text: 'Remplir ma convention').click
    #   within('td[data-head="Statut"]') do
    #     find('div.actions', text: "Votre convention est remplie par l'offreur, mais vous ne l'avez pas renseignée.")
    #   end
    #   fill_in 'Date de délibération du Conseil d’administration approuvant la convention-type', with: '10/10/2020'
    #   select('Privé hors contrat', from: 'Statut de l’établissement')
    #   click_button('Valider la convention')
    #   find('h1 span.fr-fi-arrow-right-line.fr-fi--lg', text: 'Valider la convention')
    #   click_button('Je valide la convention')
    #   find('span#alert-text',
    #        text: 'La convention est validée, le fichier pdf de la convention est maintenant disponible.')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: started_by_school_manager' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :started_by_school_manager)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('div.actions', text: 'Votre convention est remplie, mais pas validée.')
    #   end
    #   find('a.button-component-cta-button', text: 'Valider ma convention')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: validated' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :validated)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('div.actions', text: 'Votre convention est prête.')
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: signatures_started with employer' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :signatures_started)
    #   create(:signature,
    #          :employer,
    #          internship_agreement:,
    #          user_id: internship_agreement.employer.id)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('.actions.d-flex', text: "L'employeur a déjà signé. En attente de votre signature.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: signatures_started with school_manager' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :signatures_started)
    #   create(:signature,
    #          :school_manager,
    #          internship_agreement:,
    #          user_id: internship_agreement.school_manager.id)
    #   admin_officer = create(:admin_officer, school: internship_agreement.school)
    #   assert Signature.first.signatory_role == 'school_manager'
    #   sign_in(admin_officer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('.actions.d-flex',
    #          text: "Le chef d'établissement a déjà signé. En attente de la signature de l’employeur.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    #   find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    # end

    # test 'admin_officer reads multi internship agreement table with correct indications - status: signed_by_all' do
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :signed_by_all)
    #   sign_in(internship_agreement.school_manager)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     find('.actions.d-flex', text: 'Signée par toutes les parties.')
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    #   find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    # end

    # # =================== Statistician ===================

    # test 'statistician without rights attempt to reach multi internship agreement table fails' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: false))
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :draft)
    #   sign_in(internship_offer.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   find('span#alert-text', text: "Vous n'êtes pas autorisé à effectuer cette action.")
    # end

    # test 'statistician reads multi internship agreement table with correct indications - draft' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :draft,
    #                                                        internship_application:)
    #   sign_in(internship_offer.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('div.actions', text: 'À remplir par les deux parties.')
    #   end
    #   find('a.button-component-cta-button', text: 'Remplir ma convention')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: started_by_employer' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :started_by_employer,
    #                                                        internship_application:)
    #   sign_in(internship_offer.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
    #   end
    #   find('a.button-component-cta-button', text: 'Valider ma convention')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: completed_by_employer /' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :completed_by_employer,
    #                                                        internship_application:)
    #   sign_in(internship_offer.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: started_by_school_manager' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :started_by_school_manager,
    #                                                        internship_application:)
    #   sign_in(internship_offer.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: validated' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :validated,
    #                                                        internship_application:)
    #   sign_in(internship_offer.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('div.actions', text: "Votre convention est prête à être signée.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    #   find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: signatures_started with employer' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   employer = internship_offer.employer
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :signatures_started,
    #                                                        internship_application:)
    #   create(:signature,
    #          :employer,
    #          internship_agreement:,
    #          user_id: internship_agreement.employer.id)
    #   sign_in(employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature du chef d’établissement.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    #   find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: signatures_started with school_manager' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   employer = internship_offer.employer
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :signatures_started,
    #                                                        internship_application:)
    #   school_manager = internship_agreement.internship_application.student.school.school_manager
    #   create(:signature,
    #          :school_manager,
    #          internship_agreement:,
    #          user_id: school_manager.id)
    #   sign_in(employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('.actions.d-flex', text: "Le chef d'établissement a déjà signé. En attente de votre signature.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    #   find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    # end

    # test 'statistician reads multi internship agreement table with correct indications - status: signed_by_all' do
    #   internship_offer = create(:weekly_internship_offer_2nde,
    #                             employer: create(:statistician, agreement_signatorable: true))
    #   employer = internship_offer.employer
    #   employer.update(current_area_id: internship_offer.internship_offer_area.id)
    #   assert_equal employer.current_area, internship_offer.internship_offer_area
    #   internship_application = create(:weekly_internship_application, internship_offer:)
    #   internship_agreement = create(:multi_internship_agreement, aasm_state: :signed_by_all,
    #                                                        internship_application:)
    #   sign_in(internship_agreement.employer)
    #   visit_index_and_go_to_multi_internship_agreements
    #   within('td[data-head="Statut"]') do
    #     # find('.actions.d-flex', text: "Signée par toutes les parties.")
    #   end
    #   find('a.button-component-cta-button', text: 'Imprimer')
    #   find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    # end
  end
end
