# frozen_string_literal: true

require 'test_helper'
module InternshipApplicationCountersHooks
  class WeeklyFramedTest < ActiveSupport::TestCase
    setup do
      student = create(:student, :male)
      @internship_offer = create(:weekly_internship_offer_2nde)
      @internship_application = build(:weekly_internship_application, internship_offer: @internship_offer,
                                                                      student:)
    end

    test '.update_internship_offer_counters tracks internship_offer.total_applications_count' do
      @internship_application.aasm_state = :submitted
      assert_changes -> { @internship_offer.total_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.save!
        @internship_offer.reload
      end
    end

    test '.update_internship_offer_counters tracks internship_offer.total_male_approved_applications_count when student is male' do
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_changes -> { @internship_offer.reload.total_male_approved_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.employer_validate!
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters does not tracks internship_offer.total_male_approved_applications_count when student is female' do
      @internship_application.student = create(:student, gender: 'f')
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_no_changes -> { @internship_offer.reload.total_male_approved_applications_count } do
        @internship_application.employer_validate!
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters does not tracks internship_offer.total_male_approved_applications_count when student does not precise gender' do
      @internship_application.student = create(:student, gender: 'np')
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_no_changes -> { @internship_offer.reload.total_male_approved_applications_count } do
        @internship_application.employer_validate!
        @internship_application.approve!
      end
    end

    test '.update_internship_offer_counters tracks internship_offer.rejected_applications_count' do
      @internship_application.aasm_state = :submitted
      @internship_application.save!

      assert_changes -> { @internship_offer.reload.rejected_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.reject!
      end
    end

    test '.update_internship_offer_counters tracks total male and female applications_count' do
      @internship_application.student = create(:student, gender: 'm')
      @internship_application.aasm_state = :submitted
      assert_changes -> { @internship_application.internship_offer.total_male_applications_count },
                     from: 0,
                     to: 1 do
        @internship_application.save!
      end

      second_application = build(:weekly_internship_application, internship_offer: @internship_offer,
                                                                 student: create(:student, gender: 'f'))
      second_application.aasm_state = :submitted

      assert_changes -> { second_application.internship_offer.total_female_applications_count },
                     from: 0,
                     to: 1 do
        second_application.save!
      end
    end
  end
end
