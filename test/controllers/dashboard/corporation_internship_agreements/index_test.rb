require 'test_helper'
module Dashboard::CorporationInternshipAgreements
  class IndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include Rails.application.routes.url_helpers

    setup do
      @internship_agreement1 = create(:multi_internship_agreement)
      @corporation = @internship_agreement1.internship_offer.corporations.first
      @corporation_sgid = @corporation.to_sgid.to_s

      @internship_agreement2 = create(:multi_internship_agreement)
      @corporation_2 = @internship_agreement2.internship_offer.corporations.first
    end

    test 'should get index' do
      internship_agreement = @internship_agreement1
      create(:corporation_internship_agreement, corporation: @corporation, internship_agreement: internship_agreement, signed: false)

      # sign_in(create(:admin_user))

      get dashboard_corporation_internship_agreements_path(corporation_sgid: @corporation_sgid)

      assert_response :success
      assert_select 'h1', text: "Bonjour #{@corporation.employer_name}, vous avez 2 conventions de stage à signer."
      assert_select 'td', text: internship_agreement.student.presenter.full_name
    end


    test "should get index with valid corporation_sgid and internship_agreement_uuids" do
      get dashboard_corporation_internship_agreements_path(
        corporation_sgid: @corporation_sgid
      )

      assert_response :success
      assert_equal assigns(:corporation), @corporation
      assert_equal assigns(:corporation_sgid), @corporation_sgid
      # corporation_2 differs from corporation
      assert_equal assigns(:internship_agreements).map(&:id).sort, [@internship_agreement1].map(&:id).sort
    end

    test "should return not_found if corporation_sgid is invalid" do
      get dashboard_corporation_internship_agreements_path(
        corporation_sgid: "invalid_sgid"
      )

      assert_response :not_found
    end

    test "should assign empty internship_agreements if uuids param is missing" do
      get dashboard_corporation_internship_agreements_path(
        corporation_sgid: @corporation_sgid
      )

      assert_response :success
      internship_agreements = assigns(:internship_agreements)
      assert_equal [@internship_agreement1.id], internship_agreements.ids
    end

  end
end