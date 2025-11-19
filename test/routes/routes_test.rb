require 'test_helper'
require 'flipper'
require_relative '../support/feature_flipping_test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  include FeatureFlippingTestHelper
  test "should route POST /offres-de-stage/:id/flag when Flipper is enabled" do
    with_feature_flag(:enable_offer_flagging) do

      assert_routing(
        { method: 'post', path: '/offres-de-stage/1/flag' },
        { controller: 'internship_offers', action: 'flag', id: '1' }
      )
    end
  end

  test "should NOT route POST /offres-de-stage/:id/flag when Flipper is disabled" do
    with_feature_flag(:enable_offer_flagging, enabled: false) do
      assert_response :not_found if begin
        post '/offres-de-stage/1/flag'
        true
      rescue ActionController::RoutingError
        false
      end
    end
  end
end