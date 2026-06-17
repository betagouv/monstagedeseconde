# frozen_string_literal: true

class DigestMailersController < ApplicationController
  before_action -> { authorize!(:manage, :digest_mailers) }

  rescue_from CanCan::AccessDenied do
    redirect_to root_path
  end

  RAKE_TASKS = {
    low: 'digest_mailers:send_low_urgency_emails',
    medium: 'digest_mailers:send_medium_urgency_emails',
    high: 'digest_mailers:send_high_urgency_emails',
    critical: 'digest_mailers:send_critical_urgency_emails'
  }.freeze

  def new
    @action_configs = MailActionConfig::ACTION_CONFIGS
                        .keys
                        .index_with { |name| MailActionConfig.config_for(name) }
    @presenter = Presenters::DigestMailer.new
  end

  def create
    return handle_reset   if params[:reset_action].present?
    return handle_configs if params[:mail_action_configs].present?

    launch_rake_task
  end

  private

  def handle_reset
    MailActionConfig.find_by(action_name: params[:reset_action])&.destroy
    redirect_to new_digest_mailer_path,
                notice: "Configuration réinitialisée aux valeurs par défaut"
  end

  def handle_configs
    configs = params[:mail_action_configs].permit!.to_h
    rows = configs.map do |action_name, values|
      {
        action_name: action_name,
        urgency_level: values["urgency_level"],
        max_deliveries_count: values["max_deliveries_count"].to_i,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    MailActionConfig.upsert_all(rows, unique_by: :action_name)
    redirect_to new_digest_mailer_path,
                notice: "Configuration enregistrée"
  end

  def launch_rake_task
    task_name = RAKE_TASKS[params[:urgency_level]&.to_sym]
    if task_name.nil?
      return redirect_to(new_digest_mailer_path,
                         alert: "Niveau d'urgence inconnu")
    end

    Rails.application.load_tasks unless Rake::Task.task_defined?(task_name)
    Rake::Task[task_name].execute
    Rake::Task[task_name].reenable

    redirect_to new_digest_mailer_path,
                notice: "La tâche #{task_name} a été lancée"
  end
end
