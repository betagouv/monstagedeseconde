# frozen_string_literal: true

require 'test_helper'

class DigestMailersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET new is not accessible to a non-god admin' do
    school_manager = create(:user)
    sign_in(school_manager)

    get new_digest_mailer_path

    assert_response :not_found
  end

  test 'GET new is accessible to a god admin' do
    god = create(:god)
    sign_in(god)

    get new_digest_mailer_path

    assert_response :success
  end

  test 'POST create launches the matching rake task for each urgency level' do
    god = create(:god)
    sign_in(god)

    Rails.application.load_tasks unless Rake::Task.task_defined?("digest_mailers:send_low_urgency_emails")

    DigestMailersController::RAKE_TASKS.each_value do |task_name|
      Rake::Task[task_name].reenable
      assert_rake_task_runs(task_name) do
        post digest_mailers_path, params: { urgency_level: DigestMailersController::RAKE_TASKS.key(task_name) }
      end
      assert_redirected_to new_digest_mailer_path
    end
  end

  private

  def assert_rake_task_runs(task_name)
    invoked = false
    Rake::Task[task_name].clear_actions
    Rake::Task[task_name].enhance { invoked = true }
    yield
    assert invoked, "Expected rake task #{task_name} to run"
  end
end
