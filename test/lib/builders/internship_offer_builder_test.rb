# frozen_string_literal: true

require "test_helper"

module Builders
  class InternshipOfferBuilderTest < ActiveSupport::TestCase
    setup do
      @employer = create(:employer)
      @builder = Builders::InternshipOfferBuilder.new(user: @employer,
                                                       context: :web)
    end

    test "#deal_with_weeks_change returns instance when weeks param absent" do
      internship_offer = create(:weekly_internship_offer)

      result = @builder.send(:deal_with_weeks_change,
                             params: {},
                             instance: internship_offer)

      assert_equal internship_offer, result
      assert result.errors.empty?
    end

    test "#deal_with_weeks_change returns instance when weeks unchanged" do
      internship_offer = create(:weekly_internship_offer)
      week_ids = internship_offer.weeks.map(&:id)

      result = @builder.send(:deal_with_weeks_change,
                             params: { weeks: week_ids },
                             instance: internship_offer)

      assert_equal internship_offer, result
      assert result.errors.empty?
    end

    test "#deal_with_weeks_change returns instance when no approved apps" do
      internship_offer = create(:weekly_internship_offer)
      new_weeks = Week.where.not(id: internship_offer.weeks.map(&:id)).limit(1)
      return skip if new_weeks.empty?

      result = @builder.send(:deal_with_weeks_change,
                             params: { weeks: new_weeks.map(&:id) },
                             instance: internship_offer)

      assert_equal internship_offer, result
      assert result.errors.empty?
    end

    test "#deal_with_weeks_change adds error when weeks changed with approved apps" do
      internship_offer = create(:weekly_internship_offer, :week_2)
      create(:internship_application,
             :approved,
             weeks: internship_offer.weeks,
             internship_offer: internship_offer)
      new_weeks = Week.where.not(id: internship_offer.weeks.map(&:id)).limit(1)
      skip if new_weeks.empty?
      assert_raise ActiveRecord::RecordInvalid do
        @builder.send(:deal_with_weeks_change,
                      params: { week_ids: new_weeks.map(&:id) },
                      instance: internship_offer)
      end
    end
  end
end
