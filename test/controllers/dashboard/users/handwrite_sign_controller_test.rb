require 'test_helper'

module Dashboard::Users
  class HandwriteSignControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper
    def check_code(user)
      user.update(signature_phone_token_checked_at: DateTime.now)
    end

    test 'employer handwrite_sign_dashboard_internship_agreement_user_path with success' do
      if ENV['RUN_BRITTLE_TEST']
        internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
        employer = internship_agreement.employer
        employer.update(phone: '+330623456789')
        employer.create_signature_phone_token
        check_code(employer)
        sign_in(employer)

        params = {
          user: {
            id: employer.id,
            agreement_ids: internship_agreement.id,
            signature_image: File.read(Rails.root.join(*%w[test fixtures files signature]))
          }
        }

        post handwrite_sign_dashboard_user_path(id: employer.id), params: params

        follow_redirect!
        assert_response :success
        assert_equal 'Votre signature a été enregistrée pour 1 convention de stage', flash[:notice]
        assert_equal 1, Signature.count
      end
    end

    test 'when employer handwrite_sign_dashboard_internship_agreement_user_path fails with missing handwrite' do
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:mono_internship_agreement, internship_application: internship_application,
                                                           aasm_state: :validated)
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      check_code(employer)
      sign_in(employer)

      params = {
        user: {
          id: employer.id,
          agreement_ids: internship_agreement.id
        } # no handwrite_signature
      }

      post handwrite_sign_dashboard_user_path(id: employer.id), params: params
      follow_redirect!
      assert_response :success
      assert_equal 'Votre signature n\'a pas été détectée', flash[:alert]
      assert_equal 0, Signature.count
    end

    test 'employer signs with his signature_stamp instead of a handwritten signature' do
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:mono_internship_agreement, internship_application: internship_application,
                                                                aasm_state: :validated)
      employer.signature_stamp.attach(
        io: File.open(Rails.root.join('test/fixtures/files/signature.png')),
        filename: 'stamp.png',
        content_type: 'image/png'
      )
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      check_code(employer)
      sign_in(employer)

      params = {
        user: {
          id: employer.id,
          agreement_ids: internship_agreement.id,
          use_signature_stamp: '1'
        } # no signature_image : the stamp is used instead
      }

      post handwrite_sign_dashboard_user_path(id: employer.id), params: params
      follow_redirect!
      assert_response :success
      assert_equal 'Votre signature a été enregistrée pour 1 convention de stage', flash[:notice]
      assert_equal 1, Signature.count
      assert Signature.last.signature_image.attached?
      assert_equal 'signatures_started', internship_agreement.reload.aasm_state
    end

    test 'employer uploads his signature_stamp while signing' do
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:mono_internship_agreement, internship_application: internship_application,
                                                                aasm_state: :validated)
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      check_code(employer)
      sign_in(employer)

      params = {
        user: {
          id: employer.id,
          agreement_ids: internship_agreement.id,
          use_signature_stamp: '1',
          signature_stamp: fixture_file_upload('signature.png', 'image/png')
        }
      }

      post handwrite_sign_dashboard_user_path(id: employer.id), params: params
      follow_redirect!
      assert_response :success
      assert employer.reload.signature_stamp.attached?
      assert_equal 1, Signature.count
    end

    test 'employer signing with stamp fails when no stamp is attached' do
      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:mono_internship_agreement, internship_application: internship_application,
                                                                aasm_state: :validated)
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      check_code(employer)
      sign_in(employer)

      params = {
        user: {
          id: employer.id,
          agreement_ids: internship_agreement.id,
          use_signature_stamp: '1'
        } # no stamp attached, no file uploaded
      }

      post handwrite_sign_dashboard_user_path(id: employer.id), params: params
      follow_redirect!
      assert_response :success
      assert_equal 'Votre signature n\'a pas été détectée', flash[:alert]
      assert_equal 0, Signature.count
    end

    test 'when employer handwrite_sign_dashboard_internship_agreement_user_path fails with unchecked token' do
      if ENV['RUN_BRITTLE_TEST']
        internship_agreement = create(:mono_internship_agreement, aasm_state: :validated)
        employer = internship_agreement.employer
        employer.update(phone: '+330623456789')
        employer.create_signature_phone_token
        # no check_code
        sign_in(employer)

        params = {
          user: {
            id: employer.id,
            agreement_ids: internship_agreement.id,
            signature_image: File.read(Rails.root.join(*%w[test fixtures files signature]))
          }
        }

        post handwrite_sign_dashboard_user_path(id: employer.id), params: params
        follow_redirect!
        assert_response :success
        assert_equal 'Votre signature n\'a pas été enregistrée', flash[:alert]
        assert_equal 0, Signature.count
      end
    end
  end
end
