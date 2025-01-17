# frozen_string_literal: true

require 'test_helper'

module InternshipOffers::InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'PATCH #update with approve! any no custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_offer = create(:weekly_internship_offer_2nde, employer: create(:employer))
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        internship_offer:,
        user_id: student.id
      )
      assert school.school_manager.present?
      sign_in(internship_offer.employer)

      # since no main_teacher and mails to school_manager and employer are delivered later(they are queued)
      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_offer,
            uuid: internship_application.uuid
          ),
          params: { transition: :approve! }
        )
        assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 1, InternshipAgreement.count
      assert_equal internship_application.id,
                   InternshipAgreement.first.internship_application.id
      follow_redirect!
      validation_text = 'Candidature mise à jour avec succès. ' \
                        'Vous pouvez renseigner la convention dès maintenant.'
      assert_select('#alert-text', text: validation_text)
      assert_equal true, InternshipApplication.last.approved?
      assert_equal 1, InternshipAgreement.count
    end
    test 'PATCH #update with approve! any no custom message transition sends email when no school_manager' do
      school = create(:school)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_offer = create(:weekly_internship_offer_2nde, employer: create(:employer))
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        internship_offer:,
        user_id: student.id
      )
      refute school.school_manager.present?
      sign_in(internship_offer.employer)

      assert_changes -> { InternshipAgreement.count }, from: 0, to: 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_offer,
            uuid: internship_application.uuid
          ),
          params: { transition: :approve! }
        )
        assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 1, InternshipAgreement.count
      assert_equal internship_application.id,
                   InternshipAgreement.first.internship_application.id
      follow_redirect!
      validation_text = 'Candidature mise à jour avec succès. ' \
                        'Vous pouvez renseigner la convention dès maintenant.'
      assert_select('#alert-text', text: validation_text)
      assert_equal true, InternshipApplication.last.approved?
      assert_equal 1, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is a statistician it does not create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_application.internship_offer.employer.update(type: 'Users::PrefectureStatistician')

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        params = { transition: :approve! }
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            uuid: internship_application.uuid
          ),
          params: params
        )
        assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 0, InternshipAgreement.count
      assert_equal 'approved', internship_application.reload.aasm_state
      assert_equal 'read_by_employer', internship_application.state_changes.first.from_state
      assert_equal 'approved', internship_application.state_changes.last.to_state
      assert_equal internship_application.internship_offer.employer.id,
                   internship_application.state_changes.last.author_id
      assert_equal 'Users::Employer', internship_application.state_changes.last.author_type
    end

    test 'PATCH #update with approve! when employer is a statistician that can sign agreements , it does create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      employer = internship_application.internship_offer.employer
      employer.becomes(Users::PrefectureStatistician)
      employer.update(agreement_signatorable: true)

      sign_in(employer)

      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid),
          params: { transition: :approve! }
        )
        assert_redirected_to employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 1, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is an operator it does not create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      employer = internship_application.internship_offer.employer
      employer.update(type: 'Users::Operator', operator_id: create(:operator).id)
      operator = Users::Operator.find_by(id: employer.id)

      sign_in(operator)

      assert_enqueued_emails 0 do
        patch(
          dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid),
          params: { transition: :approve! }
        )
        assert_redirected_to operator.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when school has no school_manager it DOES create internship agreement anyway' do
      school = create(:school)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 2 do # Student receives email + School Manager receives email
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            uuid: internship_application.uuid
          ),
          params: { transition: :approve! }
        )
        assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 1, InternshipAgreement.count
    end

    test 'PATCH #update with approve! and a custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 1 do
        assert_changes -> { InternshipAgreement.all.count },
                       from: 0,
                       to: 1 do
          update_url = dashboard_internship_offer_internship_application_path(
            internship_offer,
            uuid: internship_application.uuid
          )
          patch(update_url, params: {
                  transition: :approve!,
                  internship_application: { approved_message: 'OK' }
                })
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
        end
      end
      internship_application.reload

      assert_equal 'OK', internship_application.approved_message
      assert InternshipApplication.last.approved?
    end

    test 'PATCH #update with employer_validate! sends email and job' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_jobs 1, only: CancelValidatedInternshipApplicationJob do
        assert_enqueued_emails 1 do
          update_url = dashboard_internship_offer_internship_application_path(
            internship_offer,
            uuid: internship_application.uuid
          )
          patch(update_url, params: {
                  transition: :employer_validate!,
                  internship_application: { approved_message: 'OK' }
                })
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :employer_validate!)
        end
      end
      internship_application.reload
      assert InternshipApplication.last.validated_by_employer?
    end

    test 'PATCH #update with approve! and update all other student internship_application' do
      if ENV['RUN_BRITTLE_TEST']
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school:)
        student = create(:student, school:, class_room:)
        internship_application = create(
          :weekly_internship_application,
          :validated_by_employer,
          user_id: student.id
        )
        internship_application_2 = create(
          :weekly_internship_application,
          :submitted,
          user_id: student.id
        )
        internship_offer = internship_application.internship_offer

        sign_in(internship_offer.employer)

        assert_enqueued_jobs 1, only: SendSmsJob do
          assert_enqueued_emails 1 do
            assert_changes -> { InternshipAgreement.all.count },
                           from: 0,
                           to: 1 do
              update_url = dashboard_internship_offer_internship_application_path(
                internship_offer,
                internship_application
              )
              patch(update_url, params: {
                      transition: :approve!,
                      internship_application: { approved_message: 'OK' }
                    })
              assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
            end
          end
        end
        internship_application.reload
        internship_application_2.reload

        assert_equal 'OK', internship_application.approved_message
        assert_equal true, internship_application.approved?
        assert_equal 'canceled_by_student_confirmation', internship_application_2.aasm_state
      end
    end

    test 'PATCH #update with approve! and update all other student internship_application and send emails to others employers' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_application_2 = create(
        :weekly_internship_application,
        :read_by_employer,
        user_id: student.id
      )
      internship_application_3 = create(
        :weekly_internship_application,
        :read_by_employer,
        user_id: student.id
      )
      internship_application_4 = create(
        :weekly_internship_application,
        :read_by_employer,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 4 do # 3 others applications emails + 1 for new agreement
        assert_changes -> { InternshipAgreement.all.count },
                       from: 0,
                       to: 1 do
          update_url = dashboard_internship_offer_internship_application_path(
            internship_offer,
            uuid: internship_application.uuid
          )
          patch(update_url, params: {
                  transition: :approve!,
                  internship_application: { approved_message: 'OK' }
                })
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
        end
      end
      internship_application.reload
      internship_application_2.reload
      internship_application_3.reload
      internship_application_4.reload

      assert_equal 'OK', internship_application.approved_message
      assert_equal true, internship_application.approved?
      assert_equal 'canceled_by_student_confirmation', internship_application_2.aasm_state
      assert_equal 'canceled_by_student_confirmation', internship_application_3.aasm_state
      assert_equal 'canceled_by_student_confirmation', internship_application_4.aasm_state
    end

    test 'PATCH #update with reject! transition sends email' do
      internship_application = create(:weekly_internship_application, :submitted)
      assert_equal 'submitted', internship_application.aasm_state

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, uuid: internship_application.uuid),
              params: { transition: :reject! })
        assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :reject!)
      end

      assert InternshipApplication.last.rejected?
      assert_equal 'rejected', InternshipApplication.last.aasm_state
      assert_equal 'submitted', InternshipApplication.last.state_changes.last.from_state
      assert_equal 'rejected', InternshipApplication.last.state_changes.last.to_state
      assert_equal internship_application.internship_offer.employer,
                   InternshipApplication.last.state_changes.last.author
    end

    test 'PATCH #update with reject! and a custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school:)
      student = create(:student, school:, class_room:)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 1 do
        update_url = dashboard_internship_offer_internship_application_path(
          internship_offer,
          uuid: internship_application.uuid
        )
        patch(update_url, params: {
                transition: :approve!,
                internship_application: { rejected_message: 'OK' }
              })
        assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      internship_application.reload

      assert_equal 'OK', internship_application.rejected_message
      assert InternshipApplication.last.approved?
    end

    test 'PATCH #update with cancel_by_employer! send email, change aasm_state' do
      internship_application = create(:weekly_internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, uuid: internship_application.uuid),
              params: { transition: :cancel_by_employer!,
                        internship_application: { canceled_by_employer_message: 'OK' } })
        assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :cancel_by_employer!)
      end
      internship_application.reload

      assert_equal 'OK', internship_application.canceled_by_employer_message
      assert internship_application.canceled_by_employer?
      assert_nil internship_application.internship_agreement
    end

    test 'PATCH #update with cancel_by_student! send email, change aasm_state' do
      student = create(:student)
      internship_application = create(:weekly_internship_application, :submitted, student:)

      sign_in(internship_application.student)

      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer, uuid: internship_application.uuid
          ),
          params: { transition: :cancel_by_student!,
                    internship_application: { canceled_by_student_message: 'OK' } }
        )
        assert_redirected_to dashboard_students_internship_applications_path(student)
      end
      internship_application.reload

      assert_equal 'OK', internship_application.canceled_by_student_message
      assert internship_application.canceled_by_student?

      follow_redirect!
      assert_select('#alert-text', text: 'Candidature mise à jour avec succès.')
    end

    test 'PATCH #update with lol! fails gracefully' do
      internship_application = create(:weekly_internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, uuid: internship_application.uuid),
              params: { transition: :lol! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      internship_application.reload

      assert internship_application.approved?
    end

    test 'PATCH when application is approved #update with cancel_by_employer! delete agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      assert internship_application.internship_agreement
      sign_in(internship_application.internship_offer.employer)

      patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, uuid: internship_application.uuid),
            params: { transition: :cancel_by_employer!,
                      internship_application: { canceled_by_employer_message_tmp: 'OK' } })

      internship_application.reload
      assert_equal 'OK', internship_application.canceled_by_employer_message
      assert internship_application.canceled_by_employer?
      assert_nil internship_application.internship_agreement
    end

    test 'PATCH when application is approved #update with cancel_by_student! delete agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      assert internship_application.internship_agreement
      sign_in(internship_application.internship_offer.employer)

      patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, uuid: internship_application.uuid),
            params: { transition: :cancel_by_student!,
                      internship_application: { canceled_by_employer_message_tmp: 'OK' } })

      internship_application.reload
      assert_equal 'OK', internship_application.canceled_by_employer_message
      assert internship_application.canceled_by_student?
      assert_nil internship_application.internship_agreement
    end
  end
end
