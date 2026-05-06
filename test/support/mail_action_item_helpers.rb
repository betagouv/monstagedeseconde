module MailActionItemHelpers
  def assert_mail_action_item_created_for(user:, action_name:, internship_application: nil, internship_agreement: nil)
    assert MailActionItem.where(
             user:,
             action_name:,
             internship_application:,
             internship_agreement:
           ).exists?,
           "Expected a MailActionItem with action_name '#{action_name}' for user #{user.email} but none was found."
  end

  def assert_mail_action_item_no_direct_email(user:, action_name:, internship_application: nil, internship_agreement: nil, &block)
    MailActionItem.delete_all
    assert_enqueued_emails 0 do
      yield if block_given?
    end

    assert_mail_action_item_created_for(
      user:,
      action_name:,
      internship_application:,
      internship_agreement:
    )
  end
end
