require 'application_system_test_case'

module Dashboard
  module Students
    class AutocompleteSchoolTest < ApplicationSystemTestCase
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'student can browse his internship_applications' do
        school = create(:school, :with_school_manager)
        student = create(:student, :when_applying, school:)
        internship_applications = {
          drafted: create(:weekly_internship_application, :drafted, internship_offer: create(:weekly_internship_offer_2nde),
                                                                    student:),
          submitted: create(:weekly_internship_application, :submitted,
                            internship_offer: create(:weekly_internship_offer_2nde), student:),
          approved: create(:weekly_internship_application, :approved,
                           internship_offer: create(:weekly_internship_offer_2nde), student:),
          rejected: create(:weekly_internship_application, :rejected,
                           internship_offer: create(:weekly_internship_offer_2nde), student:),
          canceled_by_student_confirmation: create(:weekly_internship_application, :canceled_by_student_confirmation,
                                                   internship_offer: create(:weekly_internship_offer_2nde), student:),
          validated_by_employer: create(:weekly_internship_application, :validated_by_employer,
                                        internship_offer: create(:weekly_internship_offer_2nde), student:),
          canceled_by_student: create(:weekly_internship_application, :canceled_by_student,
                                      internship_offer: create(:weekly_internship_offer_2nde), student:)
        }
        sign_in(student)
        visit '/'
        click_on 'Candidatures'
        internship_applications.each do |_aasm_state, internship_application|
          badge = internship_application.presenter(student).human_state
          find('.internship-application-status .h5.internship-offer-title',
               text: internship_application.internship_offer.title)
          find("a#show_link_#{internship_application.id}", text: badge[:actions].first[:label]).click
          find('a span.fr-icon-arrow-left-line', text: 'toutes mes candidatures').click
        end
      end

      test 'student can confirm an employer approval from his applications dashboard' do
        school = create(:school, :with_school_manager)
        student = create(:student, school:)
        internship_application = create(:weekly_internship_application, :validated_by_employer, student:)
        sign_in(student)
        visit '/'
        click_on 'Candidatures'
        find('.fr-badge.fr-badge--success', text: "ACCEPTÉE PAR L'ENTREPRISE")
        find("#show_link_#{internship_application.id}").click
        assert_equal 'validated_by_employer', internship_application.aasm_state
        assert_changes -> { InternshipAgreement.count }, from: 0, to: 1 do
          assert_changes -> { internship_application.reload.aasm_state },
                         from: 'validated_by_employer',
                         to: 'approved' do
            employer = internship_application.internship_offer.employer
            within('.fr-callout') do
              find('h3.h5.fr-callout__title', text: 'Contact en entreprise')
              assert_equal employer.presenter.formal_name, find('ul li.test-employer-name strong').text
              assert_equal employer.email, find('ul li.test-employer-email strong').text
            end
            click_button('Choisir ce stage')
            click_button('Confirmer')
          end
        end
        assert_equal 'Public', InternshipAgreement.last.legal_status
        find '.fr-badge.fr-badge--success', text: 'STAGE VALIDÉ'
        find "a#show_link_#{internship_application.id}", text: "Contacter l'employeur"
      end

      test 'student can submit an application from his applications dashboard' do
        school = create(:school, :with_school_manager)
        student = create(:student, school:)
        internship_application = create(:weekly_internship_application, :drafted, student:)
        sign_in(student)
        visit '/'
        click_on 'Candidatures'
        find('.fr-badge', text: 'BROUILLON')
        find("#show_link_#{internship_application.id}").click
        assert_equal 'drafted', internship_application.aasm_state
        assert_changes -> { internship_application.reload.aasm_state },
                       from: 'drafted',
                       to: 'submitted' do
          find('input[value="Envoyer la demande"]').click
        end
        find '.fr-badge.fr-badge--info', text: "SANS RÉPONSE DE L'ENTREPRISE"
        find "a#show_link_#{internship_application.id}", text: 'Voir'
      end

      test 'GET #show as Student with existing draft application shows the draft' do
        if ENV['RUN_BRITTLE_TEST']
          weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
          internship_offer      = create(:weekly_internship_offer_2nde)
          school                = create(:school)
          student               = create(:student, school:, class_room: create(:class_room, school:))
          internship_application = create(:weekly_internship_application,
                                          :drafted,
                                          motivation: 'au taquet',
                                          student:,
                                          internship_offer:,
                                          week: weeks.last)

          travel_to(weeks[0].week_date - 1.week) do
            sign_in(student)
            visit internship_offer_path(internship_offer)
            find('.h1', text: internship_offer.title)
            find('.h3', text: internship_offer.employer_name)
            find('.h6', text: internship_offer.street)
            find('.h4', text: 'Informations sur le stage')
            find('.reboot-trix-content', text: internship_offer.description)
            assert page.has_content? 'Stage individuel'
          end
        end
      end

      test 'student can draft, submit, and cancel(by_student) internship_applications' do
        skip 'This is ok locally but fails on CI due to slowlyness' if ENV['CI'] == 'true'
        travel_to Date.new(2024, 12, 1) do
          school = create(:school)
          student = create(:student,
                           :seconde,
                           school:,
                           class_room: create(:class_room,
                                              school:))
          internship_offer = create(:weekly_internship_offer_2nde, :week_1)

          sign_in(student)
          visit internship_offer_path(internship_offer)

          # show application form
          first(:link, 'Postuler').click

          # fill in application form
          find('#internship_application_motivation', wait: 3).native.send_keys('Je suis au taquet')
          refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen
          within('.react-tel-input') do
            find('input[name="internship_application[student_phone]"]').set('0619223344')
          end
          assert_changes lambda {
                           student.internship_applications
                                  .where(aasm_state: :drafted)
                                  .count
                         },
                         from: 0,
                         to: 1 do
            click_on 'Valider'
            page.find('#submit_application_form') # timer
          end

          assert_changes lambda {
                           student.internship_applications
                                  .where(aasm_state: :submitted)
                                  .count
                         },
                         from: 0,
                         to: 1 do
            click_on 'Envoyer'
            sleep 0.15
          end

          page.find('h4', text: "Félicitations, c'est ici que vous retrouvez toutes vos candidatures.")
        end
      end

      test 'student can update her internship_application' do
        travel_to Date.new(2024, 2, 1) do
          school = create(:school)
          student = create(:student,
                           :when_applying,
                           school:,
                           class_room: create(:class_room, school:))
          internship_offer = create(:weekly_internship_offer_2nde)
          internship_application = create(:weekly_internship_application,
                                          internship_offer:,
                                          student:)

          sign_in(student)
          visit dashboard_students_internship_applications_path(student_id: student.id)

          click_link 'Finaliser ma candidature'

          click_link 'Modifier'
          refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen

          find('h1.h2', text: 'Ma candidature')

          # fill in application form
          find('#internship_application_motivation').native.send_keys(', carrément')
          assert_no_changes lambda {
                              student.internship_applications
                                     .where(aasm_state: :drafted)
                                     .count
                            } do
            find('input.fr-btn[type="submit"][name="commit"][value="Valider ma candidature"]').click
            page.find('#submit_application_form') # timer
          end
          application = student.internship_applications.last
          assert_equal 'Suis hyper motivé, carrément', application.motivation

          click_link 'Modifier'

          find('h1.h2', text: 'Ma candidature')

          find('input.fr-btn[type="submit"][name="commit"][value="Valider ma candidature"]').click
        end
      end

      test 'submitted internship_application can be canceled by student' do
        school = create(:school)
        student = create(:student,
                         school:,
                         class_room: create(:class_room, school:))
        internship_offer = create(:weekly_internship_offer_2nde, :week_1)
        create(:weekly_internship_application,
               :submitted,
               internship_offer:,
               student:)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        click_link 'Voir'

        click_button 'Annuler la candidature'

        assert_changes lambda {
                         student.internship_applications
                                .where(aasm_state: :canceled_by_student)
                                .count
                       }, from: 0, to: 1 do
          selector = '#internship_application_canceled_by_student_message'
          find(selector)
          find(selector).set('Je ne suis plus disponible')
          # fill_in "Motif de l'annulation",	with: 'Je ne suis plus disponible'
          click_button "Confirmer l'annulation"
        end
      end

      test 'submitted internship_application can be resent by the student' do
        school = create(:school)
        student = create(:student,
                         school:,
                         class_room: create(:class_room, school:))
        internship_offer = create(:weekly_internship_offer_2nde)
        create(:weekly_internship_application, :submitted, internship_offer:, student:)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        click_link 'Voir'

        assert_changes -> { student.internship_applications.first.reload.dunning_letter_count },
                       from: 0,
                       to: 1 do
          click_button 'Renvoyer la demande'
          find("input[type='submit'][value='Renvoyer la demande']").click
        end

        click_button 'Renvoyer la demande'
        find("input[type='submit'][value='Renvoyer la demande'][disabled='disabled']")
      end

      test "confirmed internship_application can lead student to the employer's contact parameters" do
        school = create(:school)
        student = create(:student,
                         school:,
                         class_room: create(:class_room, school:))
        internship_offer = create(:weekly_internship_offer_2nde)
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        internship_offer:,
                                        student:)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        click_link "Contacter l'employeur"

        within('.fr-callout.test-data-employer') do
          find('h3.fr-callout__title', text: 'Contact en entreprise')
          find('ul li.test-employer-name', text: internship_offer.employer.presenter.formal_name)
          find('ul li.test-employer-email', text: internship_offer.employer.email)
        end
      end

      test 'when confirmed an internship_application a student cannot apply a drafted application anymore' do
        school = create(:school)
        student = create(:student,
                         :when_applying,
                         school:,
                         class_room: create(:class_room, school:))
        internship_offer_1 = create(:weekly_internship_offer_2nde, :week_1)
        internship_offer_2 = create(:weekly_internship_offer_2nde, :week_2)
        approved_application_1 = create(:weekly_internship_application,
                                        :drafted,
                                        internship_offer: internship_offer_1,
                                        student:)
        approved_application_2 = create(:weekly_internship_application,
                                        :drafted,
                                        internship_offer: internship_offer_2,
                                        student:)

        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)

        find("a#show_link_#{approved_application_1.id}").click
        find "input[type='submit'][value='Envoyer la demande']"

        approved_application_2.update_column(:aasm_state, 'approved')
        visit dashboard_students_internship_applications_path(student_id: student.id)
        click_link("Contacter l'employeur")
        assert_select "input[type='submit'][value='Envoyer la demande']", count: 0
      end

      test 'quick decision process with canceling' do
        travel_to Date.new(2024, 10, 1) do
          school = create(:school)
          student = create(:student,
                           school:,
                           class_room: create(:class_room, school:))
          internship_offer = create(:weekly_internship_offer_2nde)
          internship_application = create(:weekly_internship_application,
                                          :validated_by_employer,
                                          internship_offer:,
                                          student:)

          sgid = student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
          url = dashboard_students_internship_application_url(
            sgid:,
            student_id: student.id,
            id: internship_application.id
          )
          visit url
          click_button 'Annuler la candidature'
          selector = '#internship_application_canceled_by_student_message'
          find(selector).native.send_keys('Je ne suis plus disponible')
          click_button 'Confirmer'
          assert_equal 'canceled_by_student', internship_application.reload.aasm_state
          click_link 'Connexion' # demonstrates user is not logged in
        end
      end

      test 'quick decision process with approving' do
        travel_to Date.new(2024, 10, 1) do
          school = create(:school)
          student = create(:student,
                           school:,
                           class_room: create(:class_room, school:))
          internship_offer = create(:weekly_internship_offer_2nde)
          internship_application = create(:weekly_internship_application,
                                          :validated_by_employer,
                                          internship_offer:,
                                          student:)

          sgid = student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
          url = dashboard_students_internship_application_url(
            sgid:,
            student_id: student.id,
            id: internship_application.id
          )
          visit url
          click_button 'Choisir ce stage'
          click_button 'Confirmer'
          assert_equal 'approved', internship_application.reload.aasm_state
          within('.fr-header__tools-links') do
            click_link 'Connexion' # demonstrates user is not logged in
          end
        end
      end

      test 'reasons for rejection are explicit for students when employer rejects internship_application' do
        skip 'This is ok locally but fails on CI due to slowlyness' if ENV['CI'] == 'true'
        travel_to Date.new(2024, 10, 1) do
          employer = create(:employer)
          school = create(:school)
          student = create(:student,
                           school:,
                           class_room: create(:class_room, school:))
          internship_offer = create(:weekly_internship_offer_2nde, internship_offer_area: employer.current_area,
                                                                   employer:)
          internship_application = create(:weekly_internship_application,
                                          :submitted,
                                          internship_offer:,
                                          student:)

          sign_in(employer)
          visit dashboard_internship_offers_path
          click_link 'Candidatures'
          click_link 'Répondre'
          click_button 'Refuser'
          selector = '#internship_application_rejected_message'
          find(selector).native.send_keys('Le tuteur est malade')
          within('.fr-modal__footer') do
            click_button 'Refuser'
          end
          assert_equal 'rejected', internship_application.reload.aasm_state
          sign_out(internship_offer.employer)

          sign_in(student)
          visit dashboard_students_internship_applications_path(student_id: student.id)
          click_link 'Voir'
          assert_text 'Le tuteur est malade'
        end
      end

      test "student can apply twice if he's got one week internship only" do
        travel_to Date.new(2024, 10, 1) do
          student = create(:student, :seconde)
          internship_offer_1 = create(:weekly_internship_offer_2nde, :week_1)
          internship_offer_2 = create(:weekly_internship_offer_2nde, :week_2)
          create(:weekly_internship_application,
                 :approved,
                 student:,
                 internship_offer: internship_offer_1,
                 week: internship_offer_1.weeks.first)
          sign_in(student)
          visit dashboard_internship_offers_path
          click_link 'Candidatures'
          click_link 'Rechercher un autre stage'
          click_link internship_offer_2.title
          all('a', text: 'Postuler').first.click
          find('h1.h2', text: 'Votre candidature')
        end
      end

      test 'student cannot apply twice on the same week internship' do
        student = create(:student, :seconde)
        internship_offer_1 = create(:weekly_internship_offer_2nde, :week_1)
        internship_offer_2 = create(:weekly_internship_offer_2nde, :week_1)
        internship_application = create(:weekly_internship_application,
                                        :approved,
                                        student:,
                                        internship_offer: internship_offer_1,
                                        week: internship_offer_1.weeks.first)
        sign_in(student)
        visit dashboard_internship_offers_path
        click_link 'Candidatures'
        click_link 'Rechercher un autre stage'
        click_link internship_offer_2.title
        all('p.fr-badge.fr-badge--warning', text: 'Stage déjà validé sur cette semaine'.upcase, count: 2)
      end
    end
  end
end
