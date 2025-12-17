require 'application_system_test_case'

module Dashboard
  class SignatureTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    def code_script_enables(index)
      "document.getElementById('user-code-#{index}').disabled=false"
    end

    def code_script_assign(signature_phone_tokens, index)
      "document.getElementById('user-code-#{index}').value=#{signature_phone_tokens[index]}"
    end

    def enable_validation_button(id)
      "document.getElementById('#{id}').removeAttribute('disabled');"
    end

    test 'employer multiple signs and everything is ok' do
      # Brittle because of CI but shoud be working allright localy
      if ENV['RUN_BRITTLE_TEST'] || true
        internship_agreement = create(:mono_internship_agreement, :validated)
        student = create(:student)
        employer = internship_agreement.employer
        internship_offer = create(:weekly_internship_offer_2nde, employer:)
        create(:school_manager, school: student.school)
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        motivation: 'au taquet',
                                        student:,
                                        internship_offer:)
        internship_agreement_2 = InternshipAgreement.last
        internship_agreement_2.complete!
        internship_agreement_2.finalize!
        travel_to(weeks[0].week_date - 1.week) do
          sign_in(employer)

          visit dashboard_internship_agreements_path

          find("button[data-group-signing-id-param='#{internship_agreement.id}']").click
          find("button[data-group-signing-id-param='#{internship_agreement_2.id}']").click
          click_button('Signer en groupe (2)')

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 2 conventions de stage')
          find('input#phone_suffix').set('0612345678')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find('button#button-code-submit.fr-btn[disabled]')
          signature_phone_tokens = employer.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button('button-code-submit'))
          find('#button-code-submit').click
          find("input#submit[disabled='disabled']")
          within 'dialog' do
            find('canvas').click
          end
          assert_difference 'Signature.count', 2 do
            find('input#submit').click
          end

          signature = internship_agreement.signatures.first
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          # if Rails.application.config.active_storage.service == :local
          #   assert File.exist?(signature.local_signature_image_file_path)
          # end

          signature = internship_agreement_2.signatures.first
          assert_equal internship_agreement_2.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          # if Rails.application.config.active_storage.service == :local
          #   assert File.exist?(signature.local_signature_image_file_path)
          # end

          assert_equal signature.employer.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et signer les conventions dématérialisées')
          first_label = all('a.fr-btn.disabled')[0].text
          assert_equal 'Déjà signée', first_label
          second_label = all('a.fr-btn.disabled')[1].text
          assert_equal 'Déjà signée', second_label
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
          all('a.fr-btn--secondary.button-component-cta-button')[0].click # Imprimer
          sleep 1.2
          student = internship_agreement.student
          file_name = "Convention_de_stage_#{student.first_name.upcase}_" \
                      "#{student.last_name.upcase}.pdf"
          # assert File.exist? file_name
          # File.delete file_name
          # Dir[Signature::SIGNATURE_STORAGE_DIR + '/*'].each do |file|
          #   File.delete file
          # end
        end
      end
    end

    test 'employer multiple signs multi_agreements and everything is ok' do
      # Brittle because of CI but shoud be working allright localy
      if ENV['RUN_BRITTLE_TEST'] || true
        internship_agreement = create(:multi_internship_agreement, :validated)
        student = create(:student)
        employer = internship_agreement.employer
        internship_offer = create(:multi_internship_offer, employer:)
        create(:school_manager, school: student.school)
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        motivation: 'au taquet',
                                        student:,
                                        internship_offer:)
        internship_agreement_2 = InternshipAgreement.last
        internship_agreement_2.complete!
        internship_agreement_2.finalize!
        travel_to(weeks[0].week_date - 1.week) do
          sign_in(employer)

          visit dashboard_internship_agreements_path

          find("button[data-group-signing-id-param='#{internship_agreement.id}']").click
          find("button[data-group-signing-id-param='#{internship_agreement_2.id}']").click
          click_button('Signer en groupe (2)')

          find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 2 conventions de stage')
          click_button('Recevoir un code')

          find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
          find('button#button-code-submit.fr-btn[disabled]')
          signature_phone_tokens = employer.reload.signature_phone_token.split('')
          (0..5).to_a.each do |index|
            execute_script(code_script_enables(index))
            execute_script(code_script_assign(signature_phone_tokens, index))
          end
          execute_script(enable_validation_button('button-code-submit'))
          find('#button-code-submit').click
          find("input#submit[disabled='disabled']")
          within 'dialog' do
            find('canvas').click
          end
          assert_difference 'Signature.count', 2 do
            find('input#submit').click
          end

          signature = internship_agreement.signatures.first
          assert_equal internship_agreement.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          # if Rails.application.config.active_storage.service == :local
          #   assert File.exist?(signature.local_signature_image_file_path)
          # end

          signature = internship_agreement_2.signatures.first
          assert_equal internship_agreement_2.id, signature.internship_agreement.id
          assert_equal employer.id, signature.employer.id
          assert_equal DateTime.now, signature.signature_date
          assert_equal 'employer', signature.signatory_role
          # if Rails.application.config.active_storage.service == :local
          #   assert File.exist?(signature.local_signature_image_file_path)
          # end

          assert_equal signature.employer.phone, signature.signature_phone_number

          find('h1', text: 'Editer, imprimer et signer les conventions dématérialisées')
          first_label = all('a.fr-btn.disabled')[0].text
          assert_equal 'Déjà signée', first_label
          second_label = all('a.fr-btn.disabled')[1].text
          assert_equal 'Déjà signée', second_label
          find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
          all('a.fr-btn--secondary.button-component-cta-button')[0].click # Imprimer
          sleep 1.2
          student = internship_agreement.student
          file_name = "Convention_de_stage_#{student.first_name.upcase}_" \
                      "#{student.last_name.upcase}.pdf"
          # assert File.exist? file_name
          # File.delete file_name
          # Dir[Signature::SIGNATURE_STORAGE_DIR + '/*'].each do |file|
          #   File.delete file
          # end
        end
      end
    end

    # test 'statistician single signs and everything is ok' do
    #   # Brittle because of CI but shoud be working allright localy
    #   if ENV['RUN_BRITTLE_TEST']
    #     employer = create(:statistician, agreement_signatorable: true)
    #     weeks = [Week.find_by(number: 5, year: 2020), Week.find_by(number: 6, year: 2020)]
    #     internship_offer = create(:weekly_internship_offer_2nde, weeks:, employer:)
    #     student = create(:student, school: create(:school))
    #     create(:school_manager, school: student.school)
    #     internship_application = create(:weekly_internship_application,
    #                                     :approved,
    #                                     motivation: 'au taquet',
    #                                     student:,
    #                                     internship_offer:)
    #     internship_agreement = InternshipAgreement.last
    #     internship_agreement.complete!
    #     internship_agreement.finalize!
    #     travel_to(weeks[0].week_date - 1.week) do
    #       sign_in(employer)

    #       visit dashboard_internship_agreements_path

    #       click_button('Ajouter aux signatures')

    #       find('label', text: internship_agreement.student.presenter.full_name).click
    #       find('label', text: internship_application.student.presenter.full_name).click
    #       click_button('Signer')

    #       find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 1 convention de stage')
    #       find('input#phone_suffix').set('0612345678')
    #       click_button('Recevoir un code')

    #       find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
    #       find('button#button-code-submit.fr-btn[disabled]')
    #       signature_phone_tokens = employer.reload.signature_phone_token.split('')
    #       (0..5).to_a.each do |index|
    #         execute_script(code_script_enables(index))
    #         execute_script(code_script_assign(signature_phone_tokens, index))
    #       end
    #       execute_script(enable_validation_button('button-code-submit'))
    #       find('#button-code-submit').click
    #       find("input#submit[disabled='disabled']")
    #       within 'dialog' do
    #         find('canvas').click
    #       end
    #       assert_difference 'Signature.count', 1 do
    #         find('input#submit').click
    #       end

    #       signature = internship_agreement.signatures.first
    #       assert_equal internship_agreement.id, signature.internship_agreement.id
    #       assert_equal employer.id, signature.employer.id
    #       assert_equal DateTime.now, signature.signature_date
    #       assert_equal 'employer', signature.signatory_role
    #       if Rails.application.config.active_storage.service == :local
    #         assert File.exist?(signature.local_signature_image_file_path)
    #       end

    #       assert_equal signature.employer.phone, signature.signature_phone_number

    #       find('h1', text: 'Editer, imprimer et signer les conventions dématérialisées')
    #       first_label = all('a.fr-btn.disabled')[0].text
    #       assert_equal 'Déjà signée', first_label
    #       find('span[id="alert-text"]', text: 'Votre signature a été enregistrée')
    #       all('a.fr-btn--secondary.button-component-cta-button')[0].click # Imprimer
    #       sleep 1.2
    #       student = internship_agreement.student
    #       file_name = "Convention_de_stage_#{student.first_name.upcase}_" \
    #                   "#{student.last_name.upcase}.pdf"
    #       assert File.exist? file_name
    #       File.delete file_name
    #       Dir[Signature::SIGNATURE_STORAGE_DIR + '/*'].each do |file|
    #         File.delete file
    #       end
    #     end
    #   end
    # end

    test 'school_manager multiple signs and everything is ok' do
      # Brittle because of CI but shoud be working allright localy
      internship_agreement = create(:mono_internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      weeks = [Week.find_by(number: 5, year: 2025), Week.find_by(number: 6, year: 2025)]
      internship_offer = create(:weekly_internship_offer_2nde, weeks:)
      school = school_manager.school
      student = create(:student, school:, class_room: create(:class_room, school:))
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      motivation: 'au taquet',
                                      student:,
                                      internship_offer:)
      internship_agreement_2 = InternshipAgreement.last
      internship_agreement_2.complete!
      internship_agreement_2.finalize!
      travel_to(weeks[0].week_date - 1.week) do
        sign_in(school_manager)

        visit dashboard_internship_agreements_path

        find("button[data-group-signing-id-param='#{internship_agreement.id}']").click
        find("button[data-group-signing-id-param='#{internship_agreement_2.id}']").click
        click_button('Signer en groupe (2)')

        find('p', text: 'Vous vous apprêtez à signer en ligne ces conventions de stage. Votre signature manuscrite sera ajoutée.')

        assert_difference -> { Signature.count },  2 do
          click_button('Confirmer')
          assert_text "Les conventions ont été signées."
        end

        assert_equal 2, Signature.all.count
        signatures = Signature.all.order(:id)

        signature = signatures.first
        assert_equal internship_agreement.id, signature.internship_agreement.id
        assert_equal school_manager.id, signature.school_manager.id
        assert_equal DateTime.now, signature.signature_date
        assert_equal 'school_manager', signature.signatory_role

        signature = signatures.last
        assert_equal internship_agreement_2.id, signature.internship_agreement.id
        assert_equal school_manager.id, signature.school_manager.id
        assert_equal DateTime.now, signature.signature_date
        assert_equal 'school_manager', signature.signatory_role


        find('h1', text: 'Éditer, imprimer et signez vos conventions dématérialisées')
        first_label = all('a.fr-btn.disabled')[0].text
        assert_equal 'Déjà signée', first_label
        second_label = all('a.fr-btn.disabled')[1].text
        assert_equal 'Déjà signée', second_label
        find('span[id="alert-text"]', text: 'Les conventions ont été signées.')

        all('a.fr-btn--secondary.button-component-cta-button')[0].click # Télécharger
      end
    end

    test 'school_manager multi_agreements, multiple signs and everything is ok' do
      internship_agreement = create(:multi_internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      weeks = [Week.find_by(number: 5, year: 2025), Week.find_by(number: 6, year: 2025)]
      internship_offer = create(:multi_internship_offer, :troisieme_generale_internship_offer, weeks:)
      school = school_manager.school
      student = create(:student, school:, class_room: create(:class_room, school:))
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      motivation: 'au taquet',
                                      student:,
                                      internship_offer:)
      internship_agreement_2 = InternshipAgreement.last
      internship_agreement_2.complete!
      internship_agreement_2.finalize!
      travel_to(weeks[0].week_date - 1.week) do
        sign_in(school_manager)

        visit dashboard_internship_agreements_path(multi: true)

        find("button[data-group-signing-id-param='#{internship_agreement.id}']").click
        find("button[data-group-signing-id-param='#{internship_agreement_2.id}']").click
        click_button('Signer en groupe (2)')

        find('p', text: 'Vous vous apprêtez à signer en ligne ces conventions de stage. Votre signature manuscrite sera ajoutée.')

        assert_difference -> { Signature.count },  2 do
          click_button('Confirmer')
          assert_text "Les conventions ont été signées."
        end

        assert_equal 2, Signature.all.count
        signatures = Signature.all.order(:id)

        signature = signatures.first
        assert_equal internship_agreement.id, signature.internship_agreement.id
        assert_equal school_manager.id, signature.school_manager.id
        assert_equal DateTime.now, signature.signature_date
        assert_equal 'school_manager', signature.signatory_role

        signature = signatures.last
        assert_equal internship_agreement_2.id, signature.internship_agreement.id
        assert_equal school_manager.id, signature.school_manager.id
        assert_equal DateTime.now, signature.signature_date
        assert_equal 'school_manager', signature.signatory_role


        find('h1', text: 'Éditer, imprimer et signez vos conventions dématérialisées')
        first_label = all('a.fr-btn.disabled')[0].text
        assert_equal 'Déjà signée', first_label
        second_label = all('a.fr-btn.disabled')[1].text
        assert_equal 'Déjà signée', second_label
        find('span[id="alert-text"]', text: 'Les conventions ont été signées.')

        all('a.fr-btn--secondary.button-component-cta-button')[0].click # Télécharger
      end
    end

    test 'school_manager multiple clicks on interface' do
      internship_agreement = create(:mono_internship_agreement, :validated)
      student1 = internship_agreement.student

      school_manager = internship_agreement.school_manager
      # weeks = [Week.find_by(number: 5, year: 2020), Week.find_by(number: 6, year: 2020)]
      internship_offer = create(:weekly_internship_offer_2nde)
      school = school_manager.school
      student2 = create(:student, school:, class_room: create(:class_room, school:))
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      motivation: 'au taquet',
                                      student: student2,
                                      internship_offer:)
      internship_application.validate!
      internship_agreement_2 = InternshipAgreement.last
      internship_agreement_2.complete!
      internship_agreement_2.finalize!

      travel_to(weeks.select { |w| w.year == 2024 }.first.week_date - 1.week) do
        sign_in(school_manager)

        visit dashboard_internship_agreements_path
        general_check_box = find("table input[data-action='group-signing#toggleSignThemAll']", visible: false)
        refute general_check_box.checked?
        find("button[data-group-signing-id-param='#{internship_agreement.id}']").click

        first_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        assert first_right_button.disabled?
        second_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        refute second_right_button.disabled?

        # assert general_check_box.checked?

        find("button[data-group-signing-id-param='#{internship_agreement_2.id}']").click
        assert general_check_box.checked?
        first_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        assert first_right_button.disabled?
        second_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        assert second_right_button.disabled?

        find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer')
        find("label[for='select-general-internship-agreements']").click
        general_button = find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer')
        assert general_button.disabled?
        refute general_check_box.checked?
        first_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement.id}']")
        refute first_right_button.disabled?
        second_right_button = find("button.fr-btn[data-group-signing-id-param='#{internship_agreement_2.id}']")
        refute second_right_button.disabled?
        checkbox_1 = find("input[id='user_internship_agreement_id_#{internship_agreement.id}_checkbox']",
                          visible: false)
        refute checkbox_1.checked?
        checkbox_2 = find("input[id='user_internship_agreement_id_#{internship_agreement_2.id}_checkbox']",
                          visible: false)
        refute checkbox_2.checked?

        find("button[data-group-signing-id-param='#{internship_agreement.id}']").click
        find("button[data-group-signing-id-param='#{internship_agreement_2.id}']").click
        find('button.fr-btn[data-group-signing-target="generalCta"]', text: 'Signer en groupe (2)')
        assert general_check_box.checked?
      end
    end

    # test 'admin_officer signs when no school signature formerly exists and employer has signed already' do
    #   internship_agreement = create(:internship_agreement, :signatures_started)
    #   create(:signature, :employer, internship_agreement:)
    #   school = internship_agreement.school
    #   school.signature.purge
    #   refute school.signature.attached?
    #   admin_officer = create(:admin_officer, school:)
    #   sign_in(admin_officer)

    #   visit dashboard_internship_agreements_path
    #   click_button('Ajouter aux signatures')
    #   click_button('Signer')
    #   click_button('Confirmer')
    #   find('span#alert-text',
    #        text: "Vous devez d'abord importer la signature du chef d'établissement. Avant de signer la convention.")
    #   school.signature.attach(io: File.open('test/fixtures/files/signature.png'),
    #                           filename: 'signature.png',
    #                           content_type: 'image/png')
    #   visit dashboard_internship_agreements_path
    #   click_button('Ajouter aux signatures')
    #   click_button('Signer')
    #   click_button('Confirmer')
    #   find('span#alert-text', text: 'Les conventions ont été signées.')
    #   assert_equal 2, Signature.count
    # end

    # test 'teacher signs when school no signature formerly exists and employer has signed already' do
    #   internship_agreement = create(:internship_agreement, :signatures_started)
    #   create(:signature, :employer, internship_agreement:)
    #   school = internship_agreement.school
    #   class_room = internship_agreement.student.class_room
    #   teacher = create(:teacher, school:, class_room:)
    #   school.signature.purge
    #   sign_in(teacher)

    #   visit dashboard_internship_agreements_path
    #   click_button('Ajouter aux signatures')
    #   click_button('Signer')
    #   click_button('Confirmer')
    #   find('span#alert-text',
    #        text: "Vous devez d'abord importer la signature du chef d'établissement. Avant de signer la convention.")
    #   school.signature.attach(io: File.open('test/fixtures/files/signature.png'),
    #                           filename: 'signature.png',
    #                           content_type: 'image/png')
    #   visit dashboard_internship_agreements_path
    #   click_button('Ajouter aux signatures')
    #   click_button('Signer')
    #   click_button('Confirmer')
    #   find('span#alert-text', text: 'Les conventions ont été signées.')
    #   assert_equal 2, Signature.count
    # end

    # test 'teacher signs when school signature formerly exists and employer has signed already' do
    #   internship_agreement = create(:internship_agreement, :signatures_started)
    #   create(:signature, :employer, internship_agreement:)
    #   school = internship_agreement.school
    #   class_room = internship_agreement.student.class_room
    #   teacher = create(:teacher, school:, class_room:)
    #   sign_in(teacher)

    #   visit dashboard_internship_agreements_path
    #   click_button('Ajouter aux signatures')
    #   click_button('Signer')
    #   click_button('Confirmer')
    #   find('span#alert-text', text: 'Les conventions ont été signées.')
    #   assert_equal 2, Signature.count
    # end

    # test 'teacher signs when school signature formerly exists and employer has NOT signed already' do
    #   internship_agreement = create(:internship_agreement, :validated)
    #   school = internship_agreement.school
    #   class_room = internship_agreement.student.class_room
    #   teacher = create(:teacher, school:, class_room:)
    #   sign_in(teacher)

    #   visit dashboard_internship_agreements_path
    #   click_button('Ajouter aux signatures')
    #   click_button('Signer')
    #   click_button('Confirmer')
    #   find('span#alert-text', text: 'Les conventions ont été signées.')
    #   assert_equal 1, Signature.count
    #   assert internship_agreement.reload.signatures_started?
    #   assert page.has_content?("Le chef d'établissement a déjà signé. En attente de la signature de l’employeur")
    # end
  end
end
