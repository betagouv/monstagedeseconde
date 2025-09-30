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
        assert_redirected_to dashboard_students_internship_applications_path(student_id: student.id)
        follow_redirect!
        assert_select('.alert', text: 'Vous avez bien signé la convention de stage Fermer ×')
        assert_equal 1, internship_agreement.reload.signatures.count
        assert_equal 'student', internship_agreement.signatures.first.signatory_role
        assert_equal 'signatures_started', internship_agreement.aasm_state
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
        get legal_representative_sign_dashboard_students_internship_agreement_path(uuid: internship_agreement.uuid, student_id: student.id, student_token: student_token)
        # email is asynchronously sent when creating the signature
        assert_redirected_to dashboard_students_internship_applications_path(student_id: student.id)
        follow_redirect!
        assert_select('.alert', text: 'Vous avez bien signé la convention de stage Fermer ×')
        assert_equal 1, internship_agreement.reload.signatures.count
        assert_equal 'legal_representative', internship_agreement.signatures.first.signatory_role
        assert_equal 'signatures_started', internship_agreement.aasm_state
      rescue StandardError => e
        flunk "Exception raised: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end
end