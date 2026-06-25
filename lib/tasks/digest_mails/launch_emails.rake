namespace :digest_mailers do
  def purge_stale_items
    count = MailActionItem.overdue.delete_all
    Rails.logger.info "Purged #{count} stale MailActionItems" if count > 0
  end

  desc "send digest mails for low urgency level"
  task send_low_urgency_emails: :environment do
    purge_stale_items
    user_ids = MailActionItem.for_users
                             .with_urgency_levels(%w[low medium high critical])
                             .not_overdue
                             .pending
                             .pluck(:recipient_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        ::Services::EmployerActions::EmployerDigestMailer.perform_for_low_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No low urgency emails to send"
      Rails.logger.info "=" * 50
    end
  end

  desc "send digest mails for medium urgency level"
  task send_medium_urgency_emails: :environment do
    purge_stale_items
    user_ids = MailActionItem.for_users
                             .with_urgency_levels(%w[medium high critical])
                             .not_overdue
                             .pending
                             .pluck(:recipient_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        ::Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No medium urgency emails to send"
      Rails.logger.info "=" * 50
    end
  end

  desc "send digest mails for high urgency level"
  task send_high_urgency_emails: :environment do
    purge_stale_items
    user_ids = MailActionItem.for_users
                             .with_urgency_levels(%w[high critical])
                             .not_overdue
                             .pending
                             .pluck(:recipient_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        ::Services::EmployerActions::EmployerDigestMailer.perform_for_high_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No high urgency emails to send"
      Rails.logger.info "=" * 50
    end
  end

  desc "send digest mails for critical urgency level"
  task send_critical_urgency_emails: :environment do
    purge_stale_items
    user_ids = MailActionItem.for_users
                             .with_urgency_levels(%w[critical])
                             .not_overdue
                             .pending
                             .pluck(:recipient_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        ::Services::EmployerActions::EmployerDigestMailer.perform_for_critical_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No critical urgency emails to send"
      Rails.logger.info "=" * 50
    end
  end
end
