module Services::EmployerActions
  class Resolver
    # TODO maybe remove the action_type parameter and just resolve
    #  all action types for the given user and urgency level
    def self.call(user_id:, urgency_level:, action_type: nil)
      # ------------------------
      # new_internship_application case
      # ------------------------
      pending_application_mail_action_items = MailActionItem.where(
        user_id:,
        urgency_level:,
        action_type: :pending_application
        )
      # application which aasm_state is not :submitted are to be set as resolved
      new_applications_mail_action_items = pending_application_mail_action_items.where(action_name: "new_internship_application")
      new_applications_mail_action_items.each do |mail_action_item|
        internship_application = mail_action_item.internship_application
        unless internship_application.submitted?
          mail_action_item.update!(resolved_at: Time.current)
        end
      end

      # ------------------------
      # agreement_signed_by_all case
      # ------------------------
      agreement_signed_by_all_items = MailActionItem.where(
        user_id:,
        urgency_level:,
        action_type: :agreement_signed_by_all
      )
      agreement_signed_by_all_items.each do |item|
        agreement = item.internship_agreement
        if agreement.nil? || agreement.discarded?
          item.update!(resolved_at: Time.current)
        end
      end
    end
  end
end
