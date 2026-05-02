namespace :digest_mailers do
  desc "send digest mails for medium urgency level"
  task send_medium_urgency_emails: :environment do
    user_ids = MailActionItem.with_urgency_level("medium")
                             .not_overdue
                             .pending
                             .pluck(:user_id)
                             .uniq
    if user_ids.any?
      user_ids.each do |user_id|
        actions = ::Services::EmployerActions::DigestBuilder.build_digest_by_user_and_urgency_level(
          user_id: user_id,
          urgency_level: "medium"
        )
        next if actions.empty?

        EmployerActionsMailer.digest_email(user_id:, urgency_level: "medium", actions:)
                             .deliver_later
      end
    end
  end
end
