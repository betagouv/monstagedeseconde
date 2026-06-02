# frozen_string_literal: true

require 'test_helper'

module Public
  class InternshipAgreementsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    def build_validated_agreement
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      _, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer)
      internship_application.internship_agreement.tap do |agreement|
        agreement.update_columns(aasm_state: 'validated')
      end
    end

    test 'show without access_token returns 404 (uuid alone must not grant access)' do
      agreement = build_validated_agreement
      get public_internship_agreement_path(uuid: agreement.uuid)
      assert_response :not_found
    end

    test 'show with invalid access_token returns 404' do
      agreement = build_validated_agreement
      get public_internship_agreement_path(uuid: agreement.uuid, access_token: 'invalid_token')
      assert_response :not_found
    end

    test 'show with valid access_token renders the signature page' do
      agreement = build_validated_agreement
      get public_internship_agreement_path(uuid: agreement.uuid, access_token: agreement.access_token)
      assert_response :success
      assert_select 'h1', text: /Espace de signature/
    end

    test 'show with valid access_token but mismatched uuid returns 404' do
      agreement = build_validated_agreement
      get public_internship_agreement_path(uuid: SecureRandom.uuid, access_token: agreement.access_token)
      assert_response :not_found
    end

    test 'upload without access_token returns 404 (uuid alone must not grant PDF download)' do
      agreement = build_validated_agreement
      get upload_public_internship_agreement_path(uuid: agreement.uuid, format: :pdf)
      assert_response :not_found
    end

    test 'upload with invalid access_token returns 404' do
      agreement = build_validated_agreement
      get upload_public_internship_agreement_path(uuid: agreement.uuid,
                                                  access_token: 'invalid_token',
                                                  format: :pdf)
      assert_response :not_found
    end

    test 'after first legal representative signs, the access_token is invalidated for both reps email links' do
      agreement = build_validated_agreement
      original_token = agreement.access_token
      # Rep 1 signs
      post legal_representative_sign_public_internship_agreement_path(uuid: agreement.uuid),
           params: {
             signature: {
               uuid: agreement.uuid,
               access_token: original_token,
               student_legal_representative_nr: '1',
               student_legal_representative_full_name: agreement.student_legal_representative_full_name
             }
           }
      assert_redirected_to signed_public_internship_agreement_path(uuid: agreement.uuid)

      # Rep 2's email link (same access_token) is now dead — show is 404
      get public_internship_agreement_path(uuid: agreement.uuid, access_token: original_token)
      assert_response :not_found

      # PDF download via the same token is also dead
      get upload_public_internship_agreement_path(uuid: agreement.uuid,
                                                  access_token: original_token,
                                                  format: :pdf)
      assert_response :not_found
    end

    test 'signing does not open a devise session for the student (no ATO via intercepted access_token)' do
      agreement = build_validated_agreement
      post legal_representative_sign_public_internship_agreement_path(uuid: agreement.uuid),
           params: {
             signature: {
               uuid: agreement.uuid,
               access_token: agreement.access_token,
               student_legal_representative_nr: '1',
               student_legal_representative_full_name: agreement.student_legal_representative_full_name
             }
           }
      assert_redirected_to signed_public_internship_agreement_path(uuid: agreement.uuid)
      assert_nil session['warden.user.user.key']
    end
  end
end
