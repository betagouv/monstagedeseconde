# frozen_string_literal: true

require 'test_helper'

module Triggers
  class SingleApplicationReminderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test '.enqueue_all does queue 2nd recall job when internship_application count is equal to 1' do
      travel_to Date.new(2024, 9, 1) do
        assert_enqueued_with(job: Triggered::SingleApplicationSecondReminderJob) do
          create(:weekly_internship_application)
        end
      end
    end
  end
end
