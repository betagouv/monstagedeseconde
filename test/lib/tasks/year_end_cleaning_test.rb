require 'test_helper'

class YearEndCleaningTest < ActiveSupport::TestCase
  Monstage::Application.load_tasks if Rake::Task.tasks.none? { |task| task.name == 'cleaning:year_end' }

  YEAR_END_SUB_TASKS = %w[anonymize_internship_agreements
                          archive_students
                          archive_class_rooms
                          delete_invitations
                          clean_url_shrinker].freeze

  test 'cleaning:year_end anonymizes students, applications, agreements, signatures, class rooms ' \
       'and deletes invitations and url shrinkers' do
    travel_to Date.new(2023, 10, 1) do
      internship_application = create(:weekly_internship_application)
      student = internship_application.student
      student_email = student.email
      class_room = create(:class_room, school: student.school, name: 'Victor Hugo')
      student.update(class_room:)
      internship_agreement = create(:mono_internship_agreement)
      signature = create(:signature, :employer, internship_agreement:)
      create(:invitation)
      create(:url_shrinker, user: student)

      Rake::Task['cleaning:year_end'].invoke

      student.reload
      assert student.anonymized?
      assert student.discarded?
      assert_equal 'NA', student.first_name
      assert_equal 'NA', student.last_name
      refute_equal student_email, student.email
      assert_nil student.class_room_id

      internship_application.reload
      assert_equal 'NA', internship_application.motivation
      assert_equal 'NA', internship_application.student_address
      refute_equal student_email, internship_application.student_email

      internship_agreement.reload
      assert_equal 'NA', internship_agreement.student_full_name
      assert_equal 'NA', internship_agreement.student_phone
      assert internship_agreement.discarded?

      signature.reload
      assert_equal 'NA', signature.signature_phone_number
      assert_equal 'NA', signature.signatory_ip
      assert_equal 'NA', signature.student_legal_representative_full_name

      class_room.reload
      assert_equal 'NA', class_room.name
      assert_nil class_room.school_id

      assert_equal 0, Invitation.count
      assert_equal 0, UrlShrinker.count
    end
  ensure
    # invoke only fires once per process; reenable so a flaky-test retry reruns the tasks
    Rake::Task['cleaning:year_end'].reenable
    YEAR_END_SUB_TASKS.each { |task| Rake::Task["cleaning:#{task}"].reenable }
  end
end
