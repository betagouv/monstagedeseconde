module Services::EmployerActions
  class Resolver
    # TODO maybe remove the action_type parameter and just resolve
    #  all action types for the given user and urgency level
    def self.call(user_id:, urgency_levels:, action_type: nil)
      urgency_levels = Array(urgency_levels)
      urgency_levels.each do |urgency_level|
          # ------------------------
          # new_internship_application case
          # ------------------------
          pending_application_mail_action_items = MailActionItem.where(
            user_id:,
            urgency_level:,
            action_type: :pending_internship_application
            )
          # application which aasm_state is not :submitted are to be set as resolved
          new_applications_mail_action_items = pending_application_mail_action_items.where(action_name: "new_internship_application")
          new_applications_mail_action_items.each do |mail_action_item|
            internship_application = mail_action_item.internship_application
            next if internship_application.nil?
            if internship_application.nil? || !internship_application.submitted?
              mail_action_item.update_columns(resolved_at: Time.current)
            end
          end
        # ------------------------
        # agreement_signed_by_all case
        # ------------------------
        agreement_signed_by_all_items = MailActionItem.where(
          user_id:,
          urgency_level:,
          action_type: :pending_internship_agreement
        )
        agreement_signed_by_all_items.each do |item|
          agreement = item.internship_agreement
          if agreement.nil? || agreement.discarded?
            item.update_columns(resolved_at: Time.current)
          end
        end
      end
    end
  end
end
