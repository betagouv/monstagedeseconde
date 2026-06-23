namespace :digest_mailers do
  def send_digest_emails(scope:, levels:, mailer:, perform_method:, label:)
    user_ids = scope.with_urgency_levels(levels)
                    .not_overdue
                    .pending
                    .pluck(:recipient_id)
                    .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        mailer.public_send(perform_method, user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No #{label} emails to send"
      Rails.logger.info "=" * 50
    end
  end

  def purge_stale_items
    count = MailActionItem.overdue.delete_all
    Rails.logger.info "Purged #{count} stale MailActionItems" if count > 0
  end

  desc "send digest mails for low urgency level"
  task send_low_urgency_emails: :environment do
    purge_stale_items
    send_digest_emails(scope: MailActionItem.for_employers,
                        levels: %w[low medium high critical],
                        mailer: ::Services::EmployerActions::EmployerDigestMailer,
                        perform_method: :perform_for_low_level,
                        label: "low urgency employer")

    send_digest_emails(scope: MailActionItem.for_school_management_team,
                        levels: %w[low medium high critical],
                        mailer: ::Services::SchoolManagementActions::SchoolManagementDigestMailer,
                        perform_method: :perform_for_low_level,
                        label: "low urgency school management")
  end

  desc "send digest mails for medium urgency level"
  task send_medium_urgency_emails: :environment do
    purge_stale_items
    send_digest_emails(scope: MailActionItem.for_employers,
                        levels: %w[medium high critical],
                        mailer: ::Services::EmployerActions::EmployerDigestMailer,
                        perform_method: :perform_for_medium_level,
                        label: "medium urgency employer")

    send_digest_emails(scope: MailActionItem.for_school_management_team,
                      levels: %w[medium high critical],
                      mailer: ::Services::SchoolManagementActions::SchoolManagementDigestMailer,
                      perform_method: :perform_for_medium_level,
                      label: "medium urgency school management")
  end

  desc "send digest mails for high urgency level"
  task send_high_urgency_emails: :environment do
    send_digest_emails(scope: MailActionItem.for_employers,
                        levels: %w[high critical],
                        mailer: ::Services::EmployerActions::EmployerDigestMailer,
                        perform_method: :perform_for_high_level,
                        label: "high urgency employer")

    send_digest_emails(scope: MailActionItem.for_school_management_team,
                        levels: %w[high critical],
                        mailer: ::Services::SchoolManagementActions::SchoolManagementDigestMailer,
                        perform_method: :perform_for_high_level,
                        label: "high urgency school management")
  end

  desc "send digest mails for critical urgency level"
  task send_critical_urgency_emails: :environment do
    purge_stale_items
    send_digest_emails(scope: MailActionItem.for_employers,
                        levels: %w[critical],
                        mailer: ::Services::EmployerActions::EmployerDigestMailer,
                        perform_method: :perform_for_critical_level,
                        label: "critical urgency employer")

    send_digest_emails(scope: MailActionItem.for_school_management_team,
                        levels: %w[critical],
                        mailer: ::Services::SchoolManagementActions::SchoolManagementDigestMailer,
                        perform_method: :perform_for_critical_level,
                        label: "critical urgency school management")
  end
end
