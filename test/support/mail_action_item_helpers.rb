module MailActionItemHelpers
  UNSPECIFIED_ASSOCIATION = Object.new

  def assert_mail_action_item_created_for(recipient:, action_name:, internship_application: UNSPECIFIED_ASSOCIATION, internship_agreement: UNSPECIFIED_ASSOCIATION)
    scope = MailActionItem.where(recipient_type: recipient.class.name, recipient_id: recipient.id, action_name:)
    scope = scope.where(internship_application:) unless internship_application.equal?(UNSPECIFIED_ASSOCIATION)
    scope = scope.where(internship_agreement:) unless internship_agreement.equal?(UNSPECIFIED_ASSOCIATION)

    assert scope.exists?,
           "Expected a MailActionItem with action_name '#{action_name}' for recipient #{recipient.email} but none was found."
  end

  def assert_mail_action_item_no_direct_email(recipient:, action_name:, internship_application: UNSPECIFIED_ASSOCIATION, internship_agreement: UNSPECIFIED_ASSOCIATION, &block)
    MailActionItem.delete_all
    assert_enqueued_emails 0 do
      yield if block_given?
    end

    assert_mail_action_item_created_for(
      recipient:,
      action_name:,
      internship_application:,
      internship_agreement:
    )
  end
end
