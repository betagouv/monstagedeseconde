# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class DestroyTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'DELETE #destroy as visitor redirects to user_session_path' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        delete(dashboard_internship_offer_path(internship_offer.to_param))
        assert_redirected_to user_session_path
      end
    end

    test 'DELETE #destroy as employer not owning internship_offer redirects to user_session_path' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        sign_in(create(:employer))
        delete(dashboard_internship_offer_path(internship_offer.to_param))
        assert_redirected_to root_path
      end
    end

    test 'DELETE #destroy as statistician not owning internship_offer redirects to user_session_path' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_by_statistician_3eme)
        statistician = internship_offer.employer
        sign_in(create(:statistician))
        delete(dashboard_internship_offer_path(internship_offer.to_param))
        assert_redirected_to root_path
      end
    end

    test 'DELETE #destroy as employer owning internship_offer updates internship_offer' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        sign_in(internship_offer.employer)
        assert_changes -> { internship_offer.reload.discarded_at } do
          delete(dashboard_internship_offer_path(internship_offer.to_param))
        end
        assert_redirected_to dashboard_internship_offers_path
        assert_equal 'Votre annonce a bien été supprimée', flash[:success]
      end
    end

    test 'DELETE #destroy as statistician owning internship_offer updates internship_offer' do
      internship_offer = create(:weekly_internship_offer_by_statistician_2nde)
      statistician = internship_offer.employer
      sign_in(statistician)
      assert_changes -> { internship_offer.reload.discarded_at } do
        delete(dashboard_internship_offer_path(internship_offer.to_param))
      end
      assert_redirected_to dashboard_internship_offers_path
      assert_equal 'Votre annonce a bien été supprimée', flash[:success]
    end

    test 'DELETE #destroy twice as employer what does it do?' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        sign_in(internship_offer.employer)
        assert_changes -> { internship_offer.reload.discarded_at } do
          delete(dashboard_internship_offer_path(internship_offer.to_param))
        end
        delete(dashboard_internship_offer_path(internship_offer.to_param))
        assert_redirected_to dashboard_internship_offers_path
        assert_equal "Votre annonce n'a pas été supprimée", flash[:warning]
      end
    end
  end
end
