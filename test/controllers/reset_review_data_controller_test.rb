# frozen_string_literal: true

require 'test_helper'

class ResetReviewDataControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ENV["ENABLE_REVIEW_DATA_RESET"] = "true"
    Rails.application.reload_routes!
  end

  teardown do
    ENV.delete("ENABLE_REVIEW_DATA_RESET")
    Rails.application.reload_routes!
  end

  test "create does not enqueue RebuildReviewJob on staging platform" do
    god = create(:god)
    sign_in god

    Rails.env.stub(:staging?, true) do
      assert_no_enqueued_jobs only: RebuildReviewJob do
        post "/reset_review_data", params: { job_id: SecureRandom.uuid }
      end
    end

    assert_redirected_to root_path
  end

  test "create enqueues RebuildReviewJob when not on staging and authorized" do
    god = create(:god)
    sign_in god

    Rails.env.stub(:staging?, false) do
      Rails.env.stub(:production?, false) do
        assert_enqueued_with(job: RebuildReviewJob) do
          post "/reset_review_data", params: { job_id: SecureRandom.uuid }
        end
      end
    end

    assert_response :no_content
  end
end
