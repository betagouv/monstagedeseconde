# frozen_string_literal: true

require 'test_helper'

module InternshipsOffers
  class WeeklyFramedTest < ActiveSupport::TestCase
    setup do
      create(:department)
    end
    test 'should be valid' do
      offer = build(:weekly_internship_offer)
      assert offer.valid?
      offer.save
      assert offer.persisted?
      assert_equal offer.max_candidates, offer.remaining_seats_count
    end

    test 'test presence of fields' do
      internship_offer = InternshipOffers::WeeklyFramed.new

      assert internship_offer.invalid?
      assert_not_empty internship_offer.errors[:title]
      assert_not_empty internship_offer.errors[:sector]
      assert_not_empty internship_offer.errors[:is_public]
      assert_not_empty internship_offer.errors[:zipcode]
      assert_not_empty internship_offer.errors[:city]
      assert_not_empty internship_offer.errors[:employer_name]
      assert_not_empty internship_offer.errors[:coordinates]
    end

    test 'fulfilled internship_offers' do
      travel_to Date.new(2024, 9, 1) do
        internship_offer = create(:weekly_internship_offer,
                                  max_candidates: 2)
        assert_equal 0, InternshipOffers::WeeklyFramed.fulfilled.to_a.count
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        assert_equal 0, InternshipOffers::WeeklyFramed.fulfilled.to_a.count
        create(:weekly_internship_application,
               :submitted,
               internship_offer:)
        assert_equal 0, InternshipOffers::WeeklyFramed.fulfilled.to_a.count
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        assert_equal 1, InternshipOffers::WeeklyFramed.fulfilled.to_a.count
      end
    end

    test 'uncompleted internship_offers' do
      travel_to Date.new(2024, 9, 1) do
        weeks = Week.selectable_from_now_until_end_of_school_year.first(5).last(3)
        internship_offer = create(:weekly_internship_offer,
                                  max_candidates: 2)
        assert_equal 1, InternshipOffers::WeeklyFramed.uncompleted.count
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        assert_equal 1, InternshipOffers::WeeklyFramed.uncompleted.count
        create(:weekly_internship_application,
               :submitted,
               internship_offer:)
        assert_equal 1, InternshipOffers::WeeklyFramed.uncompleted.count
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        assert_equal 0, InternshipOffers::WeeklyFramed.uncompleted.count
      end
    end

    test 'ignore_max_candidates_reached internship_offers' do
      travel_to Date.new(2024, 1, 1) do
        internship_offer = create(:weekly_internship_offer,
                                  max_candidates: 2,
                                  published_at: nil)

        assert_equal 1, InternshipOffers::WeeklyFramed.uncompleted.to_a.count
        # assert_equal 1, InternshipOffers::WeeklyFramed.ignore_max_candidates_reached.to_a.count
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        assert_equal 1, InternshipOffers::WeeklyFramed.uncompleted.to_a.count
        create(:weekly_internship_application,
               :submitted,
               internship_offer:)
        assert_equal 1, InternshipOffers::WeeklyFramed.uncompleted.to_a.count
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        internship_offer.reload

        assert_equal 0, InternshipOffers::WeeklyFramed.uncompleted.to_a.count
      end
    end

    test 'has spots left' do
      internship_offer = create(:weekly_internship_offer, max_candidates: 2)

      assert internship_offer.has_spots_left?
      create(:weekly_internship_application, internship_offer:, aasm_state: :approved)
      create(:weekly_internship_application, internship_offer:, aasm_state: :approved)
      internship_offer.reload
      refute internship_offer.has_spots_left?
    end

    test 'sync_first_and_last_date' do
      first_io_week = Week.find_by(year: 2019, number: 50)
      last_week = Week.find_by(year: 2020, number: 2)
      internship_offer = create(:weekly_internship_offer, max_candidates: 2)

      # TO DO Update
      # assert_equal internship_offer.first_date, first_io_week.week_date.beginning_of_week
      # assert_equal internship_offer.last_date, last_week.week_date.end_of_week
    end

    test '.reverse_academy_by_zipcode works on create and save' do
      internship_offer = build(:weekly_internship_offer, zipcode: '75015')
      assert_changes -> { internship_offer.academy },
                     from: '',
                     to: 'Académie de Paris' do
        internship_offer.save
      end
    end

    test '.reverse_department_by_zipcode works on create and save' do
      create(:department, code: '62', name: 'Pas-de-Calais')
      internship_offer = build(:weekly_internship_offer, zipcode: '62000', department: 'Arras')
      assert_changes -> { internship_offer.department },
                     from: 'Arras',
                     to: 'Pas-de-Calais' do
        internship_offer.save
      end
    end

    test 'RGPD' do
      internship_offer = create(:weekly_internship_offer, tutor_name: 'Eric', tutor_phone: '0123456789',
                                                          tutor_email: 'eric@octo.com', title: 'Test', description: 'Test', employer_website: 'Test',
                                                          street: 'rue', employer_name: 'Octo', employer_description: 'Test')

      internship_offer.anonymize

      assert_not_equal 'Eric', internship_offer.tutor_name
      assert_not_equal '0123456789', internship_offer.tutor_phone
      assert_not_equal 'eric@octo.com', internship_offer.tutor_email
      assert_not_equal 'Test', internship_offer.title
      assert_not_equal 'Test', internship_offer.description
      assert_not_equal 'Test', internship_offer.employer_website
      assert_not_equal 'rue', internship_offer.street
      assert_not_equal 'Test', internship_offer.employer_name
      assert_not_equal 'Test', internship_offer.employer_description
    end

    test 'duplicate' do
      internship_offer = create(:weekly_internship_offer, description: 'abc',
                                                          employer_description: 'def')
      duplicated_internship_offer = internship_offer.duplicate
      assert internship_offer.description.present?
      assert duplicated_internship_offer.description.present?
      assert_equal internship_offer.description.strip,
                   duplicated_internship_offer.description.strip
      assert_equal internship_offer.employer_description.strip,
                   duplicated_internship_offer.employer_description.strip
    end

    test 'default max_candidates' do
      assert_equal 1, InternshipOffers::WeeklyFramed.new.max_candidates
      assert_equal 1, InternshipOffers::WeeklyFramed.new(max_candidates: '').max_candidates
    end

    test '#split_in_two with weeks on current and next year' do
      travel_to(Date.new(2020, 2, 1)) do
        within_2_weeks_week = Week.find_by(year: Week.current.year, number: Week.current.number + 2)
        first_week_of_next_year = Week.find_by(year: Week.current.year + 1, number: Week.current.number)
        internship_offer = create(
          :weekly_internship_offer,
          max_candidates: 10
        )
        assert_equal 10, internship_offer.max_candidates
        assert_equal 10, internship_offer.remaining_seats_count

        internship_application = create(:weekly_internship_application, internship_offer:,
                                                                        aasm_state: :submitted)
        internship_application.employer_validate!
        internship_application.approve!

        new_internship_offer = internship_offer.split_in_two

        assert_equal 10, internship_offer.max_candidates
        assert_equal 9, internship_offer.remaining_seats_count
        assert internship_offer.hidden_duplicate
        refute internship_offer.published?

        assert_equal 10, new_internship_offer.max_candidates
        assert_equal 10, new_internship_offer.remaining_seats_count
        refute new_internship_offer.hidden_duplicate
      end
    end
  end
end
