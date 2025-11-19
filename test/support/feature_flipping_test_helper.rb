# test/support/feature_flag_test_helper.rb
module FeatureFlippingTestHelper
  def with_feature_flag(flag_name, enabled: true)
    original_state = Flipper.enabled?(flag_name)

    if enabled
      Flipper.enable(flag_name)
    else
      Flipper.disable(flag_name)
    end

    # Reload routes for routing-affecting flags
    Rails.application.reload_routes! if routing_flag?(flag_name)

    yield
  ensure
    # Restore original state
    original_state ? Flipper.enable(flag_name) : Flipper.disable(flag_name)
    Rails.application.reload_routes! if routing_flag?(flag_name)
  end

  private

  # ------------ IMPORTANT ------------
  # list of feature flags that affect routing should be added here
  # -----------------------------------
  def routing_flag?(flag_name)
    %i[
      enable_offer_flagging
    ].include?(flag_name)
  end
end