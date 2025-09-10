require 'test_helper'

class InternshipOffersHelperTest < ActionView::TestCase
  include InternshipOffersHelper

  test 'preselect_all_weeks? returns true for new InternshipOffer without duplication' do
    @duplication = false
    object = InternshipOffer.new
    assert_equal true, preselect_all_weeks?(object)
  end

  test 'preselect_all_weeks? returns false when @duplication is true' do
    @duplication = true
    object = InternshipOffer.new
    assert_equal false, preselect_all_weeks?(object)
  end

  test 'preselect_all_weeks? returns false for persisted record' do
    @duplication = false
    object = create(:weekly_internship_offer_2nde)
    refute object.new_record?
    assert_equal false, preselect_all_weeks?(object)
  end
end

