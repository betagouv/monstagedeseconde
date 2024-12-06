# frozen_string_literal: true

require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'factory is valid' do
    weekly_internship_offer = build(:weekly_internship_offer_2nde)
    validity = weekly_internship_offer.valid?
    puts weekly_internship_offer.errors.full_messages unless validity
    assert build(:weekly_internship_offer_2nde).valid?
  end

  test 'api factory is valid' do
    assert build(:api_internship_offer_2nde).valid?
  end

  test 'create enqueue SyncInternshipOfferKeywordsJob' do
    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      create(:weekly_internship_offer_2nde)
    end
  end

  test 'destroy enqueue SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer_2nde)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.destroy
    end
  end

  test 'update title enqueues SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer_2nde)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(title: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(description: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(employer_description: 'bingo bango bang')
    end

    assert_enqueued_jobs 0, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(first_date: 2.days.from_now)
    end
  end

  test 'faulty zipcode' do
    internship_offer = create(:weekly_internship_offer_2nde)
    internship_offer.update_columns(zipcode: 'xy752')

    refute internship_offer.valid?
    assert_equal ['Code postal le code postal ne permet pas de déduire le département'],
                 internship_offer.errors.full_messages
  end

  test 'is_favorite?' do
    student = create(:student)
    other_student = create(:student)
    internship_offer = create(:weekly_internship_offer_2nde)
    other_internship_offer = create(:weekly_internship_offer_2nde)
    refute internship_offer.is_favorite?(student)

    create(:favorite, user: student, internship_offer:)
    create(:favorite, user: other_student, internship_offer: other_internship_offer)
    refute internship_offer.is_favorite?(other_student)
    assert internship_offer.is_favorite?(student)
  end

  test 'when bulking internship_offer is created, make sure area is set' do
    employer = create(:employer)
    assert_equal 1, employer.internship_offer_areas.count
    offer = build(:weekly_internship_offer_2nde, employer:)
    offer.internship_offer_area_id = nil
    assert offer.valid?
    assert offer.save
    assert offer.internship_offer_area_id.present?
    assert_equal employer.current_area_id, offer.internship_offer_area_id
  end

  test 'school_year value' do
    travel_to(Date.new(2025, 3, 1)) do
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      assert_equal 2025, internship_offer.school_year
    end
  end

  # test '.period_labels' do
  #   assert_equal '2 semaines (du 17 au 28 juin 2024)',
  #                InternshipOffer.period_labels(school_year: 2024)[:full_time]
  #   assert_equal '1 semaine (du 16 au 20 juin 2025)',
  #                InternshipOffer.period_labels(school_year: 2025)[:week_1]
  #   assert_equal '1 semaine (du 23 au 27 juin 2025)',
  #                InternshipOffer.period_labels(school_year: 2025)[:week_2]
  # end

  # test '.current_period_labels' do
  #   travel_to(Date.new(2024, 7, 17)) do
  #     assert_equal '2 semaines (du 16 au 27 juin 2025)',
  #                  InternshipOffer.current_period_labels[:full_time]
  #     assert_equal '1 semaine (du 16 au 20 juin 2025)',
  #                  InternshipOffer.current_period_labels[:week_1]
  #     assert_equal '1 semaine (du 23 au 27 juin 2025)',
  #                  InternshipOffer.current_period_labels[:week_2]
  #   end
  # # end

  # test '#current_period_label' do
  #   travel_to(Date.new(2024, 7, 17)) do
  #     internship_offer = create(:weekly_internship_offer_2nde, :week_1)
  #     assert_equal '1 semaine - du 16 au 20 juin 2025', internship_offer.current_period_label
  #   end
  # end
end
