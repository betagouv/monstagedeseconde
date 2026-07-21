require 'test_helper'

module Services
  class ArchiverTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper
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

    test 'archive_students clears the unconfirmed_email' do
      student = create(:student)
      student.update_columns(unconfirmed_email: 'pending@example.com')

      Services::Archiver.archive_students

      assert_nil student.reload.unconfirmed_email
    end

    test 'archive_students clears the free-text messages of internship applications' do
      application = travel_to(Date.new(2023, 10, 1)) { create(:weekly_internship_application) }
      application.update_columns(rejected_message: 'contient des infos perso',
                                 canceled_by_employer_message: 'contient des infos perso',
                                 canceled_by_student_message: 'contient des infos perso',
                                 approved_message: 'contient des infos perso',
                                 restored_message: 'contient des infos perso')

      Services::Archiver.archive_students

      application.reload
      assert_nil application.rejected_message
      assert_nil application.canceled_by_employer_message
      assert_nil application.canceled_by_student_message
      assert_nil application.approved_message
      assert_nil application.restored_message
    end

    test 'archive_internship_agreements anonymizes the agreements signatures' do
      signature = travel_to(Date.new(2023, 10, 1)) { create(:signature, :employer) }

      Services::Archiver.archive_internship_agreements

      signature.reload
      assert_equal 'NA', signature.signature_phone_number
      assert_equal 'NA', signature.signatory_ip
      assert_equal 'NA', signature.student_legal_representative_full_name
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

    test 'delete_anonymized_students deletes anonymized students with their dependent rows' do
      travel_to(Date.new(2023, 10, 1)) do
        internship_agreement = create(:mono_internship_agreement)
        create(:signature, :employer, internship_agreement:)
        student = internship_agreement.student
        create(:url_shrinker, user: student)
        Favorite.create!(user: student, internship_offer: internship_agreement.internship_application.internship_offer)
        employer = internship_agreement.employer

        Services::Archiver.archive_students
        # factory jobs reference records deleted below; drop them so assert_enqueued_with
        # only has to deserialize the purge jobs
        clear_enqueued_jobs
        Services::Archiver.delete_anonymized_students

        assert_equal 0, Users::Student.count
        assert_equal 0, InternshipApplication.count
        assert_equal 0, InternshipAgreement.count
        assert_equal 0, Signature.count
        assert_equal 0, InternshipApplicationStateChange.count
        assert_equal 0, Favorite.count
        assert_equal 0, UrlShrinker.count
        assert User.exists?(employer.id), 'employer must not be deleted'
        assert_enqueued_with(job: ActiveStorage::PurgeJob)
      end
    end

    test 'delete_anonymized_students never touches non-anonymized students' do
      kept_student = create(:student)
      anonymized_student = create(:student)
      anonymized_student.anonymize(send_email: false)

      Services::Archiver.delete_anonymized_students

      assert Users::Student.exists?(kept_student.id), 'non-anonymized student must be kept'
      refute Users::Student.exists?(anonymized_student.id)
    end

    test 'delete_anonymized_students detaches inappropriate offers instead of deleting them' do
      inappropriate_offer = travel_to(Date.new(2023, 10, 1)) do
        create(:inappropriate_offer, user: create(:student))
      end
      inappropriate_offer.user.anonymize(send_email: false)

      Services::Archiver.delete_anonymized_students

      inappropriate_offer.reload
      assert_nil inappropriate_offer.user_id, 'moderation report must be kept, only detached'
    end

    test 'delete_anonymized_students deletes every student across multiple batches' do
      students = create_list(:student, 5)
      students.each { |student| student.anonymize(send_email: false) }

      Services::Archiver.delete_anonymized_students(batch_size: 2)

      assert_equal 0, Users::Student.where(anonymized: true).count
    end
  end
end
