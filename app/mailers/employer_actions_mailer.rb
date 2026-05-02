class EmployerActionsMailer < ApplicationMailer
  def digest_email(user_id:, actions:, urgency_level:)
    @user = User.find(user_id)
    @actions = actions
    @urgency_level = urgency_level
    @actions.map do |action_type, items|
      items.map do |item|
        case action_type
        when "pending_application"
          internship_application = InternshipApplication.find(item.payload["internship_application_id"])
          item.define_singleton_method(:internship_application) { internship_application }
        end
      end
    end

    send_email(to: @user.email, subject: "Résumé de vos actions en attente")
  end
end
