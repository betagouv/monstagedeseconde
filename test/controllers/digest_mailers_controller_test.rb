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

  test "GET new exposes action_configs to the view" do
    god = create(:god)
    sign_in(god)

    get new_digest_mailer_path

    assert_response :success
    assert_not_nil assigns(:action_configs)
    assert_includes assigns(:action_configs).keys,
                    "new_internship_application"
  end

  test "POST create with config params saves configs and redirects" do
    god = create(:god)
    sign_in(god)

    post digest_mailers_path, params: {
      mail_action_configs: {
        "new_internship_application" => {
          urgency_level: "high",
          max_deliveries_count: "3"
        }
      }
    }

    assert_redirected_to new_digest_mailer_path
    assert_equal "high",
                 MailActionConfig.find_by(
                   action_name: "new_internship_application"
                 ).urgency_level
  end

  test "POST create with reset param deletes the record and redirects" do
    god = create(:god)
    sign_in(god)
    MailActionConfig.create!(
      action_name: "new_internship_application",
      urgency_level: "critical",
      max_deliveries_count: 5
    )

    post digest_mailers_path, params: {
      reset_action: "new_internship_application"
    }

    assert_redirected_to new_digest_mailer_path
    assert_nil MailActionConfig.find_by(
      action_name: "new_internship_application"
    )
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
