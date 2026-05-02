module Services::EmployerActions
  class MailActionSubscriber
    def emit(event)
      actions, internship_application = mail_action_items_finder(event)
      return if actions.empty?

      deal_with_pending_application_state_change(
        actions,
        internship_application: internship_application
      )
      Rails.logger.info "MailActionSubscriber - emit - event: #{event.name} - actions count: #{actions.count}"
    end



    private

    def deal_with_pending_application_state_change(mail_actions, internship_application:)
      # many cases will add up here
      # 1 - if the application is no longer submitted,
      # we can mark as stale all pending_application mail_action_items
      # related to this application
      no_longer_submitted = mail_actions.where(action_name: "new_internship_application")
      unless internship_application.submitted?
        no_longer_submitted.update_all(stale_at: Time.current)
      end
    end

    def mail_action_items_finder(event)
      internship_application_id = event.data[:internship_application_id]
      return unless event.name == "internship_application.state_changed"

      internship_application = InternshipApplication.find_by(id: internship_application_id)
      return if internship_application.nil?

      mail_actions = MailActionItem.where(
        action_type: :pending_application,
        resolved_at: nil,
        payload: { internship_application_id: internship_application_id }
      )
      [ mail_actions, internship_application ]
    end
  end
end
