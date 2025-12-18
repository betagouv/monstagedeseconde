require 'test_helper'
module Dashboard::CorporationInternshipAgreements
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @internship_agreement1 = create(:multi_internship_agreement)
      @corporation = @internship_agreement1.internship_offer.corporations.first
      @corporation_sgid = @corporation.to_sgid.to_s

      @internship_agreement2 = create(:multi_internship_agreement)
      @corporation_2 = @internship_agreement2.internship_offer.corporations.first
    end

    # test "should update signed status and redirect on success" do

    # NOT USED ANYMORE
    
    #   assert_equal 10, CorporationInternshipAgreement.count
    #   internship_agreement = @internship_agreement1
    #   corporation_internship_agreement = CorporationInternshipAgreement.find_by(
    #     corporation: @corporation,
    #     internship_agreement: internship_agreement
    #   )
    #   refute corporation_internship_agreement.signed

    #   puts '================================'
    #   puts "corporation_internship_agreement : #{corporation_internship_agreement}"
    #   puts '================================'
    #   puts ''

    #   patch dashboard_corporation_internship_agreement_path(id: corporation_internship_agreement.id),
    #         params: {
    #           corporation_internship_agreement: {
    #             corporation_sgid: @corporation_sgid,
    #             internship_agreement_uuid: internship_agreement.uuid,
    #             signed: '1'
    #           }
    #         }

    #   assert_redirected_to dashboard_corporation_internship_agreements_path(
    #     corporation_sgid: @corporation_sgid
    #   )
    #   assert_equal 'La convention a été mise à jour avec succès.', flash[:notice]

    #   assert corporation_internship_agreement.reload.signed
    # end

    # test "should return not_found if corporation_sgid is invalid on update" do
    #   corporation_internship_agreement = create(
    #     :corporation_internship_agreement,
    #     corporation: @corporation,
    #     internship_agreement: @internship_agreement1,
    #     signed: false
    #   )
    #   assert_raises ActionController::UrlGenerationError do
    #     patch dashboard_corporation_internship_agreement_path, params: {
    #       corporation_internship_agreement: {
    #         corporation_sgid: "invalid_sgid",
    #         internship_agreement_uuid: @internship_agreement1.uuid,
    #         internship_agreement_uuids: [@internship_agreement1.uuid],
    #         signed: '1'
    #       }
    #     }
    #   end
    # end
  end
end