require 'test_helper'

module Services
  class DescriptionScoringTest < ActiveSupport::TestCase
    include ThirdPartyTestHelpers
    test 'description_score' do
      internship_offer = create(:weekly_internship_offer_2nde)
      stub_description_score(instance: internship_offer, score: 0.5) do
        score = Services::DescriptionScoring.new(instance: internship_offer)
                                            .perform
        assert_equal 15, score
      end
    end
  end
end
