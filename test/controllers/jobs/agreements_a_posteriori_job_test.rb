require 'test_helper'

class AgreementsAPosterioriJobTest < ActiveJob::TestCase
  test 'when agreement_signatorable goes from false to true a job is launched' do
    statistician = create(:statistician, agreement_signatorable: false)
    assert_not statistician.agreement_signatorable
    assert_enqueued_with(job: AgreementsAPosterioriJob) do
      statistician.update(agreement_signatorable: true)
    end
  end

  test 'no job whe agreement_signatorable going from false to true on an employer profile' do
    employer = create(:employer)
    assert employer.agreement_signatorable
    assert_no_performed_jobs do
      employer.update(agreement_signatorable: true)
    end
  end
end
