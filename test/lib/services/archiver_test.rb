require 'test_helper'

module Services
  class ArchiverTest < ActiveSupport::TestCase
    test 'archive_students anonymizes fresh kept students' do
      student = create(:student)
      refute student.anonymized?
      refute student.discarded?

      Services::Archiver.archive_students

      student.reload
      assert student.anonymized?
      assert student.discarded?
      assert_equal 'NA', student.first_name
      assert_equal 'NA', student.last_name
      assert_nil student.birth_date
    end

    test 'archive_students skips students already anonymized' do
      # anonymized but still kept (not discarded) -> must be skipped by the anonymized: false filter,
      # otherwise the task would reprocess it on every run.
      already = create(:student)
      already.update_columns(anonymized: true, first_name: 'KEEP', last_name: 'KEEP')
      fresh = create(:student)

      Services::Archiver.archive_students

      already.reload
      assert already.anonymized?
      assert_equal 'KEEP', already.first_name, 'already-anonymized student must be left untouched'
      assert_equal 'KEEP', already.last_name

      assert fresh.reload.anonymized?, 'fresh student must still be archived'
    end

    test 'archive_students randomizes email while preserving its domain' do
      student = create(:student, email: 'alice@example.com')

      Services::Archiver.archive_students

      student.reload
      refute_equal 'alice@example.com', student.email
      assert student.email.end_with?('@example.com'), 'email domain must be preserved'
    end

    test 'archive_students anonymizes the students internship applications' do
      application = travel_to(Date.new(2023, 10, 1)) { create(:weekly_internship_application) }

      Services::Archiver.archive_students

      application.reload
      assert_equal 'NA', application.motivation
      assert_equal 'NA', application.student_email
      assert_equal 'NA', application.student_address
      assert application.student.reload.anonymized?
    end

    test 'archive_students processes every student across multiple batches' do
      # Small batch size forces several batches; mutating the filtered `anonymized` column
      # mid-iteration must not skip or reprocess any student (keyset batching by id).
      students = create_list(:student, 5)

      Services::Archiver.archive_students(batch_size: 2)

      assert students.all? { |s| s.reload.anonymized? }, 'all students must be archived exactly once'
      assert_equal 0, Users::Student.kept.where(anonymized: false).count
    end

    test 'archive_students is idempotent across runs' do
      create(:student)
      create(:student)

      Services::Archiver.archive_students
      assert_equal 0, Users::Student.kept.where(anonymized: false).count

      # second run has nothing left to archive and must not raise
      assert_nothing_raised { Services::Archiver.archive_students }
      assert_equal 0, Users::Student.kept.where(anonymized: false).count
    end
  end
end
