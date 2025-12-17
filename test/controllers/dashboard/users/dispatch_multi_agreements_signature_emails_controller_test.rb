require 'test_helper'

module Dashboard::Users
  class DispatchMultiAgreementsSignatureEmailsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test 'employer dispatch_multi_agreements_signature_dashboard_user_path with success' do
      internship_agreement_1 = create(:multi_internship_agreement, aasm_state: :validated)
      internship_agreement_2 = create(:multi_internship_agreement, aasm_state: :validated)
      employer = internship_agreement_1.internship_offer.employer
      sign_in(employer)

      params = {
        user: {
          id: employer.id,
          internship_agreement_ids: [internship_agreement_1.id, internship_agreement_2.id]
        }
      }
      assert_emails 10 do
        post dispatch_multi_agreements_signature_dashboard_user_path(id: employer.id), params: params
      end
      
      follow_redirect!
      assert_response :success
      assert_equal 'Les emails de signature ont été envoyés aux employeurs.', flash[:notice]
      corporation_internship_agreements = CorporationInternshipAgreement.all
      assert_equal 10 , corporation_internship_agreements.count
      assert corporation_internship_agreements.all? { |cia| cia.signed == false }
      assert_equal 5, corporation_internship_agreements.where(internship_agreement_id: internship_agreement_1.id).count
      assert_equal 5, corporation_internship_agreements.where(internship_agreement_id: internship_agreement_2.id).count

    end
  end
end
