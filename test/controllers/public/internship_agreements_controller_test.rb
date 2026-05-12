# frozen_string_literal: true

require 'test_helper'

module Public
  class InternshipAgreementsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    def build_agreement
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      _employer, offer = create_employer_and_offer_2nde
      application = create(:weekly_internship_application, :approved,
                           student: student,
                           internship_offer: offer)
      [student, create(:mono_internship_agreement, :validated, internship_application: application)]
    end

    test 'show is denied to anonymous user when only uuid is provided' do
      _student, agreement = build_agreement
      get public_internship_agreement_path(uuid: agreement.uuid)
      assert_redirected_to root_path
      assert_equal 'Convention introuvable', flash[:alert]
    end

    test 'upload is denied to anonymous user when only uuid is provided' do
      _student, agreement = build_agreement
      get upload_public_internship_agreement_path(uuid: agreement.uuid, format: :pdf)
      assert_redirected_to root_path
      assert_equal 'Convention introuvable', flash[:alert]
    end

    test 'show with an invalid access_token does not fall back to uuid lookup' do
      _student, agreement = build_agreement
      get public_internship_agreement_path(uuid: agreement.uuid, access_token: 'nope')
      assert_redirected_to root_path
      assert_equal 'Convention introuvable', flash[:alert]
    end

    test 'show with a valid access_token grants access and marks the session' do
      _student, agreement = build_agreement
      get public_internship_agreement_path(uuid: agreement.uuid, access_token: agreement.access_token)
      assert_response :success

      get upload_public_internship_agreement_path(uuid: agreement.uuid, format: :pdf)
      assert_response :success
      assert_equal 'application/pdf', response.media_type
    end

    test 'legal_representative_sign does not sign the user in as the student' do
      _student, agreement = build_agreement
      post legal_representative_sign_public_internship_agreement_path(uuid: agreement.uuid),
           params: {
             signature: {
               uuid: agreement.uuid,
               access_token: agreement.access_token,
               student_legal_representative_nr: '1',
               student_legal_representative_full_name: agreement.student_legal_representative_full_name
             }
           }
      assert_redirected_to public_internship_agreement_path(uuid: agreement.uuid)
      assert_nil controller.current_user
      assert_nil agreement.reload.access_token
      assert_equal 1, agreement.signatures.count
    end

    test 'legal_representative_sign rejects an invalid access_token' do
      _student, agreement = build_agreement
      post legal_representative_sign_public_internship_agreement_path(uuid: agreement.uuid),
           params: {
             signature: {
               uuid: agreement.uuid,
               access_token: 'invalid',
               student_legal_representative_nr: '1',
               student_legal_representative_full_name: agreement.student_legal_representative_full_name
             }
           }
      assert_redirected_to root_path
      assert_equal 0, agreement.reload.signatures.count
      refute_nil agreement.access_token
    end

    test 'legal_representative_sign rejects a blank access_token' do
      _student, agreement = build_agreement
      post legal_representative_sign_public_internship_agreement_path(uuid: agreement.uuid),
           params: {
             signature: {
               uuid: agreement.uuid,
               access_token: '',
               student_legal_representative_nr: '1',
               student_legal_representative_full_name: agreement.student_legal_representative_full_name
             }
           }
      assert_redirected_to root_path
      assert_equal 0, agreement.reload.signatures.count
    end

    test 'signed-in authorized user can download the pdf via uuid' do
      student, agreement = build_agreement
      sign_in(student)
      get upload_public_internship_agreement_path(uuid: agreement.uuid, format: :pdf)
      assert_response :success
      assert_equal 'application/pdf', response.media_type
    end
  end
end
