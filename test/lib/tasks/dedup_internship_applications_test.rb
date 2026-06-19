require 'test_helper'

class DedupInternshipApplicationsTest < ActiveSupport::TestCase
  Monstage::Application.load_tasks

  setup do
    Rake::Task['data_migrations:dedup_internship_applications'].reenable
    # Temporarily drop the unique index so duplicates can exist (state we're cleaning).
    # The DROP runs inside the test transaction and is rolled back at teardown.
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS uniq_applications_per_user_offer')
  end

  test 'keeps the most advanced state and deletes the rest' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)
      submitted = create(:weekly_internship_application, :submitted, student:, internship_offer: offer)
      rejected = build(:weekly_internship_application, :rejected, student:, internship_offer: offer)
      rejected.save(validate: false)
      approved = build(:weekly_internship_application, :approved, student:, internship_offer: offer)
      approved.save(validate: false)

      assert_equal 3, InternshipApplication.where(user_id: student.id, internship_offer_id: offer.id).count

      capture_io { Rake::Task['data_migrations:dedup_internship_applications'].invoke }

      remaining = InternshipApplication.where(user_id: student.id, internship_offer_id: offer.id)
      assert_equal 1, remaining.count
      assert_equal approved.id, remaining.first.id
    end
  end

  test 'breaks ties with most recent updated_at when states match' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)
      older = create(:weekly_internship_application, :submitted, student:, internship_offer: offer)
      older.update_column(:updated_at, 5.days.ago)
      newer = build(:weekly_internship_application, :submitted, student:, internship_offer: offer)
      newer.save(validate: false)
      newer.update_column(:updated_at, 1.day.ago)

      capture_io { Rake::Task['data_migrations:dedup_internship_applications'].invoke }

      remaining = InternshipApplication.where(user_id: student.id, internship_offer_id: offer.id)
      assert_equal 1, remaining.count
      assert_equal newer.id, remaining.first.id
    end
  end

  test 'no-op when there are no duplicates' do
    create(:weekly_internship_application, :submitted)
    assert_no_difference -> { InternshipApplication.count } do
      capture_io { Rake::Task['data_migrations:dedup_internship_applications'].invoke }
    end
  end
end
