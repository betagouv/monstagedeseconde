# frozen_string_literal: true

require 'test_helper'
class RebuildReviewJobTest < ActiveJob::TestCase
  test 'perform broadcasts progress updates' do
    job_id = 'test123'
    expected_broadcasts_in_method = 3
    # Prepare a spy for ActionCable.server.broadcast
    broadcasted = []
    create(:weekly_internship_offer)
    RebuildReviewJob.stub_any_instance(:remove_steps, nil) do
      RebuildReviewJob.stub_any_instance(:creation_steps, nil) do
        ActionCable.server.stub(:broadcast, ->(channel, data) { broadcasted << [channel, data] }) do
          assert_enqueued_jobs 0 do
            RebuildReviewJob.new.perform(job_id)
          end
        end
      end
    end

    # Check that 10 broadcasts were made
    assert_equal expected_broadcasts_in_method, broadcasted.size
    # Check channel name and progress values
    broadcasted.each_with_index do |(channel, data), i|
      assert_equal "progress_#{job_id}", channel
    end
  end
end
