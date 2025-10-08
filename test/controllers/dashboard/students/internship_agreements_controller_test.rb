# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Students
    class InternshipAgreementsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'student can sign internship agreement' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)

        employer, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                   internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        sign_in(student)
        get sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id)
        # email is asynchronously sent when creating the signature
        assert_redirected_to legal_representative_email_check_dashboard_students_internship_agreement_path(student_id: student.id, uuid: internship_agreement.uuid)
        follow_redirect!
        assert_select('.alert', text: 'Votre signature a été validée Fermer ×')
        assert_equal 1, internship_agreement.reload.signatures.count
        assert_equal 'student', internship_agreement.signatures.first.signatory_role
        assert_equal 'signatures_started', internship_agreement.aasm_state
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test 'student cannot sign twice the internship agreement' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        employer, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
        internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :signed_by_student_only, internship_application: internship_application)
        sign_in(student)
        get sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id)
        # email is asynchronously sent when creating the signature
        assert_redirected_to dashboard_students_internship_applications_path(
          student_id: student.id,
        )
        follow_redirect!
        assert_select('.alert', text: 'Vous avez déjà signé cette convention de stage Fermer ×')
        assert_equal 1, internship_agreement.reload.signatures.count
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test "legal representative can sign internship agreement" do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        student_token = student.to_sgid.to_s

        e_, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                    internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        refute_nil internship_agreement.access_token
        assert_not_nil internship_agreement.student_legal_representative_full_name
        assert_not_nil internship_agreement.student_legal_representative_email
        sign_in(student)
        post legal_representative_sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id),
             params: {
               signature: {
                 uuid: internship_agreement.uuid,
                 student_id: student.id,
                 access_token: internship_agreement.access_token,
                 student_legal_representative_full_name: internship_agreement.student_legal_representative_full_name
               }
             }
        # email is asynchronously sent when creating the signature
        assert_redirected_to new_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid)
        follow_redirect!
        assert_select('.fr-alert', text: "La convention de stage a déjà été signée par #{internship_agreement.student_legal_representative_full_name}")
        assert_equal 1, internship_agreement.reload.signatures.count
        assert_equal 'student_legal_representative', internship_agreement.signatures.first.signatory_role
        assert_equal 'signatures_started', internship_agreement.aasm_state
        last_signature = Signature.last
        assert_equal last_signature.student_legal_representative_full_name, internship_agreement.student_legal_representative_full_name
        assert_equal last_signature.user_id, student.id
        assert_nil  internship_agreement.access_token
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test 'legal representative cannot sign twice the internship agreement' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        student_token = student.to_sgid.to_s

        e_, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                    internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        refute_nil internship_agreement.access_token
        assert_not_nil internship_agreement.student_legal_representative_full_name
        assert_not_nil internship_agreement.student_legal_representative_email
        sign_in(student)
        post legal_representative_sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id),
             params: {
               signature: {
                 uuid: internship_agreement.uuid,
                 student_id: student.id,
                 access_token: internship_agreement.access_token,
                 student_legal_representative_full_name: internship_agreement.student_legal_representative_full_name
               }
             }
        assert_redirected_to new_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid)
        follow_redirect!
        assert_select('.fr-alert', text: "La convention de stage a déjà été signée par #{internship_agreement.student_legal_representative_full_name}")
        assert_equal 1, internship_agreement.reload.signatures.count
        assert_equal 'student_legal_representative', internship_agreement.signatures.first.signatory_role
        assert_equal 'signatures_started', internship_agreement.aasm_state

        post legal_representative_sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id),
             params: {
               signature: {
                 uuid: internship_agreement.uuid,
                 student_id: student.id,
                 access_token: internship_agreement.access_token,
                 student_legal_representative_full_name: internship_agreement.student_legal_representative_full_name
               }
             }
        assert_redirected_to root_path
        follow_redirect!
        assert_select('.alert', text: "Le représentant légal #{internship_agreement.student_legal_representative_full_name} a déjà signé cette convention de stage Fermer ×")
        assert_equal 1, internship_agreement.reload.signatures.count
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test 'legal representative cannot sign with invalid token' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        student_token = student.to_sgid.to_s

        e_, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                    internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        refute_nil internship_agreement.access_token
        assert_not_nil internship_agreement.student_legal_representative_full_name
        assert_not_nil internship_agreement.student_legal_representative_email
        sign_in(student)
        post legal_representative_sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id),
             params: {
               signature: {
                 uuid: internship_agreement.uuid,
                 student_id: student.id,
                 access_token: 'invalid_token',
                 student_legal_representative_full_name: internship_agreement.student_legal_representative_full_name
               }
             }
        assert_redirected_to root_path
        follow_redirect!
        assert_select('.alert', text: 'Convention introuvable Fermer ×')
        assert_equal 0, internship_agreement.reload.signatures.count
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test 'should handle RecordNotFound on sign action' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)

        employer, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                   internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        sign_in(student)
        get sign_dashboard_students_internship_agreement_path(uuid: 'nonexistent', student_id: student.id)
        assert_redirected_to root_path
        follow_redirect!
        assert_select('.alert', text: "Vous n'êtes pas autorisé à effectuer cette action. Fermer ×")
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test 'new' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)
        student_token = student.to_sgid.to_s

        e_, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                    internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        refute_nil internship_agreement.access_token
        assert_not_nil internship_agreement.student_legal_representative_full_name
        assert_not_nil internship_agreement.student_legal_representative_email

        get new_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid,
                                                             access_token: internship_agreement.access_token,
                                                             student_id: student.id)
        assert_response :success
        assert_select 'h1', text: "Espace de signature de la convention de stage destiné aux responsables légaux de #{student.presenter.full_name}"
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

      test 'legal_representative_email_check' do
        school = create(:school, :with_school_manager)
        student = create(:student, school: school)

        e_, internship_offer = create_employer_and_offer_2nde
        internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                    internship_offer: internship_offer)
        internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
        sign_in(student)
        get legal_representative_email_check_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id)
        assert_response :success
        assert_select 'h1', text: "Votre signature est validée"
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end

    end
  end
end