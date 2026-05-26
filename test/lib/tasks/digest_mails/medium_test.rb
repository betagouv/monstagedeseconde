require "test_helper"

class DigestMailsMediumTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  TASK_NAME = "digest_mailers:send_medium_urgency_emails".freeze

  Monstage::Application.load_tasks

  setup do
    Rake::Task[TASK_NAME].reenable
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
