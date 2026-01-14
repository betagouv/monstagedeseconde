require 'test_helper'
module Dashboard::CorporationInternshipAgreements
  class MultiSignTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @internship_agreement1 = create(:multi_internship_agreement, :validated)
      @corporation = @internship_agreement1.internship_offer.corporations.first
      @corporation_sgid = @corporation.to_sgid.to_s
    end

    def create_agreement_on_same_corporation
      internship_application = create(:weekly_internship_application, :approved, internship_offer: @internship_agreement1.internship_offer)
      @internship_agreement2 = internship_application.internship_agreement
      @internship_agreement2.update!(aasm_state: :validated)
    end

    test 'second internhip_agreement on same corporation' do
      create_agreement_on_same_corporation
      assert_equal @internship_agreement1.internship_offer.corporations.first.id, @internship_agreement2.internship_offer.corporations.first.id
    end

    test "should multi sign internship agreements and redirect on success" do
      create_agreement_on_same_corporation #=> @internship_agreement2
      uuids = [@internship_agreement1.uuid, @internship_agreement2.uuid]
      corporation_internship_agreements = CorporationInternshipAgreement.where(
        corporation: @corporation,
        internship_agreement_id: [@internship_agreement1.id, @internship_agreement2.id]
      )
      corporation_internship_agreements.update_all(signed: false)

      patch multi_sign_dashboard_corporation_internship_agreement_path(id: @corporation.id), params: {
        corporation_internship_agreement: {
          corporation_sgid: @corporation_sgid,
          internship_agreement_uuids: uuids
        }
      }

      # assert_redirected_to dashboard_corporation_internship_agreement_path(
      #   corporation_sgid: @corporation_sgid,
      #   internship_agreement_uuids: uuids
      # )
      assert_equal 'Les conventions ont été mises à jour avec succès.', flash[:notice]
      assert corporation_internship_agreements.reload.all?(&:signed)
    end

    test "should handle blank uuids in multi_sign" do
      patch multi_sign_dashboard_corporation_internship_agreement_path(id: @corporation.id), params: {
        corporation_internship_agreement: {
          corporation_sgid: @corporation_sgid,
          internship_agreement_uuids: [@internship_agreement1.uuid, ""]
        }
      }

      # assert_redirected_to dashboard_corporation_internship_agreement_path(corporation_sgid: @corporation_sgid)
      assert_equal 'Les conventions ont été mises à jour avec succès.', flash[:notice]
      assert CorporationInternshipAgreement.find_by(
        corporation: @corporation,
        internship_agreement: @internship_agreement1
      ).signed
    end

    test "should return not_found if corporation_sgid is invalid in multi_sign" do
      patch multi_sign_dashboard_corporation_internship_agreement_path(id: @corporation.id), params: {
        corporation_internship_agreement: {
          corporation_sgid: "invalid_sgid",
          internship_agreement_uuids: [@internship_agreement1.uuid]
        }
      }
      assert_response :not_found
    end

    test "should render index with unprocessable_entity if uuid is invalid in multi_sign" do
      patch multi_sign_dashboard_corporation_internship_agreement_path(id: @corporation.id), params: {
        corporation_internship_agreement: {
          corporation_sgid: @corporation_sgid,
          internship_agreement_uuids: ["invalid_uuid"]
        }
      }
      follow_redirect!
      assert_template :index
    end

    test "should handle empty internship_agreement_uuids in multi_sign" do
      patch multi_sign_dashboard_corporation_internship_agreement_path(id: @corporation.id), params: {
        corporation_internship_agreement: {
          corporation_sgid: @corporation_sgid,
          internship_agreement_uuids: []
        }
      }
      # assert_redirected_to dashboard_corporation_internship_agreement_path(corporation_sgid: @corporation_sgid)
      assert_equal "Aucune convention n'a été sélectionnée.", flash[:notice]
    end

    test "#multi_reminder_email" do
      employer = @corporation.multi_corporation.internship_offer.employer
      sign_in employer

      corporation_internship_agreements = CorporationInternshipAgreement.where(
        internship_agreement_id: @internship_agreement1.id
      )

      get multi_reminder_email_dashboard_internship_agreement_path(uuid: @internship_agreement1.uuid)

      assert_redirected_to dashboard_internship_agreements_path
      assert_equal "Aucun email n'a encore été envoyé jusqu'ici aux responsables de stage.", flash[:alert]
      
      @internship_agreement1.multi_corporation.update!(signatures_launched_at: Time.now - 1.day)
      
      get multi_reminder_email_dashboard_internship_agreement_path(uuid: @internship_agreement1.uuid)
      
      assert_redirected_to dashboard_internship_agreements_path
      assert_equal 'Les emails de rappel ont été envoyés aux responsables de stage.', flash[:notice]
    end

  end
end