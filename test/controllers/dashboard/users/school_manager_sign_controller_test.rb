require 'test_helper'

module Dashboard::Users
  class ResetPhoneNumberControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'admin_officer signs when school signature already exists' do
      internship_agreement = create(:mono_internship_agreement, :validated)
      school = internship_agreement.school
      assert school.signature.attached?
      admin_officer = create(:admin_officer, school: )
      sign_in(admin_officer)
      assert_changes -> {internship_agreement.signatures.count}, from: 0, to: 1 do
        post school_management_sign_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      end
      assert_redirected_to dashboard_internship_agreements_path
      assert_equal 1, Signature.count
      assert_equal Signature.last.signatory_role, 'admin_officer'
      assert_equal Signature.last.internship_agreement, internship_agreement
    end

    test 'admin_officer signs when no school signature already exists' do
      internship_agreement = create(:mono_internship_agreement, :validated)
      school = internship_agreement.school
      school.signature.purge
      refute school.signature.attached?
      admin_officer = create(:admin_officer, school: )
      sign_in(admin_officer)
      assert_no_changes -> {internship_agreement.signatures.count} do
        post school_management_sign_dashboard_internship_agreement_path(uuid: internship_agreement.uuid)
      end
      assert_redirected_to dashboard_internship_agreements_path
    end
  end
end
