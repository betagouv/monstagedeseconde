class InvitationMailer < ApplicationMailer
  def staff_invitation(from:, invitation:)
    @from        = from.email
    @school_name = from.school.name
    @from_name   = from.presenter.formal_name
    @invitation  = invitation
    @to          = invitation.email
    @invitation_first_name = invitation.first_name
    @invitation_last_name  = invitation.last_name
    @school_manager_id = invitation.user_id
    @url = site_url
    @link = school_management_login_url

    mail(
      from: @from,
      to: @to,
      subject: 'Invitation à rejoindre 1élève1stage'
    )
  end
end
