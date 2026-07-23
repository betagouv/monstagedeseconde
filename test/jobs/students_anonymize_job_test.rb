require 'test_helper'

class StudentsAnonymizeJobTest < ActiveJob::TestCase
  test 'perform anonymizes every kept student' do
    student = create(:student)

    StudentsAnonymizeJob.perform_now

    student.reload
    assert student.anonymized?
    assert student.discarded?
    assert_equal 'NA', student.first_name
  end
end
