namespace :digest_mailers do
  desc "send digest mails for low urgency level"
  task send_low_urgency_emails: :environment do
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

    school_management_ids = MailActionItem.for_school_management_team
                                          .with_urgency_levels(%w[low medium high critical])
                                          .not_overdue
                                          .pending
                                          .pluck(:recipient_id)
                                          .uniq
    if school_management_ids.any?
      school_management_ids.each do |user_id|
        ::Services::SchoolManagementActions::SchoolManagementDigestMailer.perform_for_low_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No low urgency school management emails to send"
      Rails.logger.info "=" * 50
    end

    student_ids = MailActionItem.for_students
                                .with_urgency_levels(%w[low medium high critical])
                                .not_overdue
                                .pending
                                .pluck(:recipient_id)
                                .uniq
    if student_ids.any?
      student_ids.each do |user_id|
        ::Services::StudentActions::StudentDigestMailer.perform_for_low_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No low urgency student emails to send"
      Rails.logger.info "=" * 50
    end
  end

  desc "send digest mails for medium urgency level"
  task send_medium_urgency_emails: :environment do
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

    school_management_ids = MailActionItem.for_school_management_team
                                          .with_urgency_levels(%w[medium high critical])
                                          .not_overdue
                                          .pending
                                          .pluck(:recipient_id)
                                          .uniq
    if school_management_ids.any?
      school_management_ids.each do |user_id|
        ::Services::SchoolManagementActions::SchoolManagementDigestMailer.perform_for_medium_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No medium urgency school management emails to send"
      Rails.logger.info "=" * 50
    end

    student_ids = MailActionItem.for_students
                                .with_urgency_levels(%w[medium high critical])
                                .not_overdue
                                .pending
                                .pluck(:recipient_id)
                                .uniq
    if student_ids.any?
      student_ids.each do |user_id|
        ::Services::StudentActions::StudentDigestMailer.perform_for_medium_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No medium urgency student emails to send"
      Rails.logger.info "=" * 50
    end
  end

  desc "send digest mails for high urgency level"
  task send_high_urgency_emails: :environment do
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

    school_management_ids = MailActionItem.for_school_management_team
                                          .with_urgency_levels(%w[high critical])
                                          .not_overdue
                                          .pending
                                          .pluck(:recipient_id)
                                          .uniq
    if school_management_ids.any?
      school_management_ids.each do |user_id|
        ::Services::SchoolManagementActions::SchoolManagementDigestMailer.perform_for_high_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No high urgency school management emails to send"
      Rails.logger.info "=" * 50
    end

    student_ids = MailActionItem.for_students
                                .with_urgency_levels(%w[high critical])
                                .not_overdue
                                .pending
                                .pluck(:recipient_id)
                                .uniq
    if student_ids.any?
      student_ids.each do |user_id|
        ::Services::StudentActions::StudentDigestMailer.perform_for_high_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No high urgency student emails to send"
      Rails.logger.info "=" * 50
    end
  end

  desc "send digest mails for critical urgency level"
  task send_critical_urgency_emails: :environment do
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

    school_management_ids = MailActionItem.for_school_management_team
                                          .with_urgency_levels(%w[critical])
                                          .not_overdue
                                          .pending
                                          .pluck(:recipient_id)
                                          .uniq
    if school_management_ids.any?
      school_management_ids.each do |user_id|
        ::Services::SchoolManagementActions::SchoolManagementDigestMailer.perform_for_critical_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No critical urgency school management emails to send"
      Rails.logger.info "=" * 50
    end

    student_ids = MailActionItem.for_students
                                .with_urgency_levels(%w[critical])
                                .not_overdue
                                .pending
                                .pluck(:recipient_id)
                                .uniq
    if student_ids.any?
      student_ids.each do |user_id|
        ::Services::StudentActions::StudentDigestMailer.perform_for_critical_level(user_id: user_id)
      end
    else
      Rails.logger.info "=" * 50
      Rails.logger.info "No critical urgency student emails to send"
      Rails.logger.info "=" * 50
    end
  end
end
