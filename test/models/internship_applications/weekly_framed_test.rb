# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class InternshipApplicationTest < ActiveSupport::TestCase
    test 'is not applicable twice on same week by same student' do
      travel_to Date.new(2019, 1, 1) do
        weeks = Week.selectable_from_now_until_end_of_school_year.first(2).last(1)
        student = create(:student)
        internship_offer = create(:weekly_internship_offer)
        internship_application_1 = create(:weekly_internship_application, student: student,
                                                                          internship_offer: internship_offer)
        assert internship_application_1.valid?
        internship_application_2 = build(:weekly_internship_application, student: student,
                                                                        internship_offer: internship_offer)
        refute internship_application_2.valid?
      end
    end

    test 'is not applicable twice on different week by same student' do
      weeks = Week.selectable_from_now_until_end_of_school_year.first(3).last(2)
      travel_to Date.new(2019, 1, 1) do
        student = create(:student)
        internship_offer = create(:weekly_internship_offer)
        internship_application_1 = create(:weekly_internship_application,
                                          internship_offer: internship_offer,
                                          student: student)
        assert internship_application_1.valid?
        internship_application_2 = build(:weekly_internship_application,
                                        internship_offer: internship_offer,
                                        student: student)
        refute internship_application_2.valid?
      end
    end

    test 'application updates remaining_seats_count along with approved applications' do
      offer = create(:weekly_internship_offer)
      assert_equal offer.max_candidates, offer.remaining_seats_count
      application = create(:weekly_internship_application, internship_offer: offer)
      assert_equal offer.max_candidates, offer.remaining_seats_count
      assert_equal "drafted", application.aasm_state

      application.submit!
      assert_equal "submitted", application.aasm_state
      assert_equal offer.max_candidates, offer.reload.remaining_seats_count

      offer.need_update! # avoids requires_update validation
      application.employer_validate!
      application.approve!
      assert_equal "approved", application.aasm_state
      assert_equal 1, application.internship_offer.internship_applications.approved.count
      offer.reload
      assert_equal 1, offer.max_candidates
      assert_equal 0, offer.remaining_seats_count
    end

    test 'application updates offer favorites along with approved applications' do
      offer = create(:weekly_internship_offer, max_candidates: 1)
      favorite = create(:favorite, internship_offer: offer)
      assert_equal Favorite.count, 1
      other_favorite = create(:favorite)
      application = create(:weekly_internship_application, internship_offer: offer)
      
      application.submit!
      assert_equal Favorite.count, 2
      
      application.employer_validate!
      application.approve!
      assert_equal "approved", application.aasm_state
      assert_equal Favorite.count, 1
    end
    
    test 'application updates old offer favorites along with approved applications' do
      old_offer = create(:weekly_internship_offer, last_date: 7.days.ago)
      favorite = create(:favorite, internship_offer: old_offer)
      assert_equal Favorite.count, 1
      other_favorite = create(:favorite)
      application = create(:weekly_internship_application, internship_offer: old_offer)
      
      application.submit!
      assert_equal Favorite.count, 2
      
      application.employer_validate!
      application.approve!
      assert_equal "approved", application.aasm_state
      assert_equal Favorite.count, 1
      assert_operator Favorite.last.internship_offer.last_date, :>, Time.now
    end

    test 'scope :expirable' do
      start_date = Date.new(2020,3, 1)
      internship_application = nil
      travel_to start_date do
        weeks = Week.selectable_from_now_until_end_of_school_year.first(2).first(1)
        internship_offer = create(:weekly_internship_offer)
        internship_application = create(:weekly_internship_application, :submitted,
                                                                        internship_offer: internship_offer,
                                                                        submitted_at: start_date)
        assert_equal 0, InternshipApplication.expirable.count
      end
      travel_to start_date + InternshipApplication::EXPIRATION_DURATION + 7.days do
        assert_equal 1, InternshipApplication.expirable.count
        internship_application.update_columns(examined_at: Time.now, aasm_state: :examined)
        assert_equal 0, InternshipApplication.expirable.count
      end
      travel_to start_date + InternshipApplication::EXPIRATION_DURATION + InternshipApplication::EXTENDED_DURATION.days do
        assert_equal 1, InternshipApplication.expirable.count
      end
    end

    test 'approving applications let some applications be canceled by student, when validated is one week long' do
      student = create(:student)
      internship_offer_1 = create(:weekly_internship_offer, :week_1)
      internship_offer_2 = create(:weekly_internship_offer, :week_2)
      internship_offer_3 = create(:weekly_internship_offer, :full_time)
      create(:weekly_internship_application, :validated_by_employer, student: student, internship_offer: internship_offer_1)
      internship_application = create(:weekly_internship_application, :validated_by_employer, student: student, internship_offer: internship_offer_2)
      create(:weekly_internship_application, :validated_by_employer, student: student, internship_offer: internship_offer_3)
      assert_changes -> { InternshipApplication.canceled_by_student_confirmation.count}, from: 0, to: 1 do
        internship_application.approve!
      end
    end

    test 'approving applications let some applications be canceled by student, when validated is two week long' do
      student = create(:student)
      internship_offer_1 = create(:weekly_internship_offer, :week_1)
      internship_offer_2 = create(:weekly_internship_offer, :week_2)
      internship_offer_3 = create(:weekly_internship_offer, :full_time)
      create(:weekly_internship_application, :validated_by_employer, student: student, internship_offer: internship_offer_1)
      create(:weekly_internship_application, :validated_by_employer, student: student, internship_offer: internship_offer_2)
      internship_application = create(:weekly_internship_application, :validated_by_employer, student: student, internship_offer: internship_offer_3)
      assert_changes -> { InternshipApplication.canceled_by_student_confirmation.count}, from: 0, to: 2 do
        internship_application.approve!
      end
    end
  end
end
