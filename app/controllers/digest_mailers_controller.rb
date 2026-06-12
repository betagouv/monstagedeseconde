# frozen_string_literal: true

class DigestMailersController < ApplicationController
  before_action -> { authorize!(:manage, :digest_mailers) }

  RAKE_TASKS = {
    low: 'digest_mailers:send_low_urgency_emails',
    medium: 'digest_mailers:send_medium_urgency_emails',
    high: 'digest_mailers:send_high_urgency_emails',
    critical: 'digest_mailers:send_critical_urgency_emails'
  }.freeze

  def new; end

  def create
    task_name = RAKE_TASKS[params[:urgency_level].to_sym]
    return redirect_to(new_digest_mailer_path, alert: "Niveau d'urgence inconnu") if task_name.nil?

    Rails.application.load_tasks unless Rake::Task.task_defined?(task_name)
    Rake::Task[task_name].execute
    Rake::Task[task_name].reenable

    redirect_to new_digest_mailer_path, notice: "La tâche #{task_name} a été lancée"
  end
end
