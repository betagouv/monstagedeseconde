namespace :digest_mailers do
  desc "send digest mails for low urgency level"
  task send_low_urgency_emails: :environment do
    user_ids = MailActionItem.with_urgency_level("low")
                             .not_overdue
                             .pending
                             .pluck(:user_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        ::Services::EmployerActions::DigestMailer.perform_for_low_level(user_id: user_id)
      end
    else
      Rails.logger.info "No low urgency emails to send"
    end
  end

  desc "send digest mails for medium urgency level"
  task send_medium_urgency_emails: :environment do
    user_ids = MailActionItem.with_urgency_level("medium")
                             .not_overdue
                             .pending
                             .pluck(:user_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        ::Services::EmployerActions::DigestMailer.perform_for_medium_level(user_id: user_id)
      end
    else
      Rails.logger.info "No medium urgency emails to send"
    end
  end
end
