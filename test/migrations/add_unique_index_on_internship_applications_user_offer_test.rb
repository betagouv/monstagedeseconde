require 'test_helper'
require Rails.root.join('db/migrate/20260520214758_add_unique_index_on_internship_applications_user_offer')

# Tests the migration's OWN inline dedup (a deliberate mirror of the rake task
# data_migrations:dedup_internship_applications). We exercise the private
# dedup_duplicate_applications directly so we don't touch the CONCURRENTLY index
# build, and assert it deletes duplicates in the intended order:
#   1. keep the most advanced application state
#   2. then the most advanced (kept) agreement
#   3. then the most recently updated
class AddUniqueIndexOnInternshipApplicationsUserOfferTest < ActiveSupport::TestCase
  setup do
    # Drop the unique index so duplicates can exist (the state the migration cleans).
    # DDL is transactional in Postgres, so this is rolled back at teardown.
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS uniq_applications_per_user_offer')
    @migration = AddUniqueIndexOnInternshipApplicationsUserOffer.new
  end

  test 'keeps the most advanced application state and deletes the rest' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)
      submitted = persisted_application(:submitted, student, offer)
      persisted_application(:rejected, student, offer)
      approved = persisted_application(:approved, student, offer)

      run_dedup

      assert_equal [approved.id], remaining_ids(student, offer)
    end
  end

  test 'breaks application-state ties by the most advanced agreement (over updated_at)' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)

      less_advanced = persisted_application(:approved, student, offer)
      more_advanced = persisted_application(:approved, student, offer)
      validated_agreement = create(:mono_internship_agreement, internship_application: less_advanced,
                                                               aasm_state: 'validated')
      create(:mono_internship_agreement, internship_application: more_advanced, aasm_state: 'signed_by_all')

      # Make the LESS advanced agreement the most recently updated: proves the agreement
      # rank wins over the updated_at tie-break.
      less_advanced.update_column(:updated_at, 1.day.ago)
      more_advanced.update_column(:updated_at, 5.days.ago)

      run_dedup

      assert_equal [more_advanced.id], remaining_ids(student, offer)
      assert_not InternshipAgreement.exists?(validated_agreement.id)
    end
  end

  test 'full ordering: most advanced state then most advanced agreement wins' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)

      persisted_application(:expired, student, offer)
      persisted_application(:submitted, student, offer)
      approved_validated = persisted_application(:approved, student, offer)
      create(:mono_internship_agreement, internship_application: approved_validated, aasm_state: 'validated')
      winner = persisted_application(:approved, student, offer)
      create(:mono_internship_agreement, internship_application: winner, aasm_state: 'signed_by_all')

      # Shuffle updated_at so the winner is not trivially the most recent.
      winner.update_column(:updated_at, 10.days.ago)

      run_dedup

      assert_equal [winner.id], remaining_ids(student, offer)
    end
  end

  test 'breaks ties by most recent updated_at when state and agreement rank match' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)
      older = persisted_application(:submitted, student, offer)
      older.update_column(:updated_at, 5.days.ago)
      newer = persisted_application(:submitted, student, offer)
      newer.update_column(:updated_at, 1.day.ago)

      run_dedup

      assert_equal [newer.id], remaining_ids(student, offer)
    end
  end

  test 'cascades: destroys the agreement and signatures of deleted duplicates' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer = create(:weekly_internship_offer_2nde)

      keeper = persisted_application(:approved, student, offer)
      create(:mono_internship_agreement, internship_application: keeper, aasm_state: 'signed_by_all')

      deleted = persisted_application(:approved, student, offer)
      deleted_agreement = create(:mono_internship_agreement, internship_application: deleted,
                                                            aasm_state: 'signatures_started')
      deleted_signature = create(:signature, :employer, internship_agreement: deleted_agreement)

      # keeper (signed_by_all) outranks deleted (signatures_started) regardless of recency.
      keeper.update_column(:updated_at, 9.days.ago)

      run_dedup

      assert_equal [keeper.id], remaining_ids(student, offer)
      assert_not InternshipAgreement.exists?(deleted_agreement.id), 'deleted application agreement should cascade'
      assert_not Signature.exists?(deleted_signature.id), 'deleted agreement signatures should cascade'
    end
  end

  test 'removes every duplicate couple, keeping exactly one each' do
    travel_to Date.new(2024, 1, 1) do
      student = create(:student)
      offer_a = create(:weekly_internship_offer_2nde)
      offer_b = create(:weekly_internship_offer_2nde)
      persisted_application(:submitted, student, offer_a)
      persisted_application(:rejected, student, offer_a)
      persisted_application(:submitted, student, offer_b)
      persisted_application(:expired, student, offer_b)

      run_dedup

      assert_equal 1, remaining_ids(student, offer_a).size
      assert_equal 1, remaining_ids(student, offer_b).size
      assert_empty duplicate_couples
    end
  end

  test 'no-op when there are no duplicates' do
    create(:weekly_internship_application, :submitted)
    assert_no_difference -> { InternshipApplication.count } do
      run_dedup
    end
  end

  private

  def run_dedup
    capture_io { @migration.send(:dedup_duplicate_applications) }
  end

  # build + save(validate: false) keeps full control: it skips the :approved factory's
  # after(:create) agreement auto-creation and the approved-state validations.
  def persisted_application(trait, student, offer)
    application = build(:weekly_internship_application, trait, student:, internship_offer: offer)
    application.save(validate: false)
    application
  end

  def remaining_ids(student, offer)
    InternshipApplication.where(user_id: student.id, internship_offer_id: offer.id).pluck(:id)
  end

  def duplicate_couples
    InternshipApplication.group(:user_id, :internship_offer_id).having('COUNT(*) > 1').count
  end
end
