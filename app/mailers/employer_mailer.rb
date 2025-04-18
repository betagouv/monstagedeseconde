# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def internship_application_submitted_email(internship_application:)
    @internship_application = internship_application
    @internship_offer       = @internship_application.internship_offer
    recipients_email        = internship_application.filtered_notification_emails
    @prez_application       = @internship_application.presenter(internship_application.internship_offer.employer)
    @url = dashboard_internship_offer_internship_application_url(
      @internship_offer,
      uuid: @internship_application.uuid
    )
    @url_more_options = "#{@url}?sgid=#{@internship_application.to_sgid}"
    @url_accept       = "#{@url_more_options}&opened_modal=accept"
    @url_refuse       = "#{@url_more_options}&opened_modal=refuse"
    send_email(to: recipients_email,
               subject: 'Une candidature vous attend, veuillez y répondre')
  end

  def internship_application_canceled_by_student_email(internship_application:)
    @internship_application = internship_application
    recipients_email        = internship_application.filtered_notification_emails
    send_email(to: recipients_email,
               subject: 'Information - Une candidature a été annulée')
  end

  def internship_application_approved_with_agreement_email(internship_agreement:)
    internship_application = internship_agreement.internship_application
    recipients_email       = internship_application.filtered_notification_emails
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @url = dashboard_internship_offer_internship_applications_url(
      internship_offer_id: @internship_offer.id,
      uuid: internship_application.uuid,
      mtm_campaign: "Offreur - Convention Ready to Edit#internship-application-#{internship_application.id}"
    ).html_safe

    send_email(
      to: recipients_email,
      subject: 'Veuillez compléter la convention de stage.'
    )
  end

  def school_manager_finished_notice_email(internship_agreement:)
    internship_application = internship_agreement.internship_application
    recipients_email       = internship_application.filtered_notification_emails
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @school_manager        = internship_agreement.school_manager
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'Offreur - Convention Ready to Print'
    ).html_safe

    send_email(
      to: recipients_email,
      subject: 'Imprimez et signez la convention de stage.'
    )
  end

  def notify_others_signatures_started_email(internship_agreement:, employer:, school_management:)
    internship_application = internship_agreement.internship_application
    recipients_email       = internship_application.filtered_notification_emails
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = employer
    @school_manager        = school_management
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'Offreur - Convention Ready to Sign'
    ).html_safe

    send_email(
      to: recipients_email,
      subject: 'Une convention de stage attend votre signature'
    )
  end

  def notify_others_signatures_finished_email(internship_agreement:, employer:, school_management:)
    internship_application = internship_agreement.internship_application
    recipients_email       = internship_application.filtered_notification_emails
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @school_manager        = school_management
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'Offreur - Convention Ready to Sign'
    ).html_safe

    send_email(
      to: @employer.email,
      subject: 'Dernière ligne droite pour la convention de stage'
    )
  end

  def transfer_internship_application_email(internship_application:, employer_id:, email:, message:)
    @internship_application = internship_application
    @internship_offer       = internship_application.internship_offer
    @employer               = @internship_offer.employer
    @employer_full_name     = @employer.presenter.full_name
    @student_full_name      = @internship_application.student.presenter.full_name
    @message                = message
    @url = dashboard_internship_offer_internship_application_url(
      internship_offer_id: @internship_offer.id,
      uuid: @internship_application.uuid,
      token: @internship_application.access_token
    ).html_safe

    send_email(
      to: email,
      cc: @employer.email,
      subject: "Transfert d'une candidature à un stage de 2de"
    )
  end

  def resend_internship_application_submitted_email(internship_application:)
    @internship_application = internship_application
    recipients_email        = internship_application.filtered_notification_emails

    send_email(
      to: recipients_email,
      subject: '[Relance] Vous avez une candidature en attente'
    )
  end

  def internship_application_approved_for_an_other_internship_offer_email(internship_application:)
    recipients_email  = internship_application.filtered_notification_emails
    @internship_offer = internship_application.internship_offer
    student           = internship_application.student
    @prez_stud        = student.presenter
    @employer         = @internship_offer.employer
    @url = dashboard_internship_offer_internship_applications_url(
      internship_offer_id: @internship_offer.id,
      id: internship_application.id,
      mtm_campaign: 'Offreur - internship application cancelled'
    ).html_safe

    send_email(
      to: recipients_email,
      subject: 'Un candidat a préféré un autre stage'
    )
  end

  def team_member_invitation_email(team_member_invitation:, user:)
    @email = team_member_invitation.invitation_email
    @inviter_presenter = team_member_invitation.inviter.presenter
    # user may be nil
    @user = user unless user.nil?
    @subscription_url = new_user_registration_url
    @url = dashboard_team_member_invitations_url

    mail(
      to: @email,
      subject: 'Invitation à rejoindre une équipe'
    )
  end

  # every monday and thursday at 8:00
  def pending_internship_applications_reminder_email(employer:, pending_application_ids:)
    @employer = employer
    @pending_application_ids = pending_application_ids
    @url = dashboard_internship_offers_url(
      mtm_campaign: 'Offreur - Candidatures en attente'
    ).html_safe

    send_email(
      to: @employer.email,
      subject: 'Candidatures en attente, veuillez y répondre'
    )
  end

  def cleaning_notification_email(id)
    @employer = Users::Employer.find(id)
    @title    = 'Suppression de votre compte imminente'
    subject   = @title
    @hello    = "#{@employer.presenter.formal_name},"
    @header   = 'Votre compte sera supprimé dans 14 jours : '
    @content  = 'nous avons effectivement constaté que votre participation ' \
                'à la plateforme 1eleve1stage.education.gouv.fr ' \
                'est très faible depuis deux ans.<br/> ' \
                "La suppression de votre compte n'est naturellement pas notre souhait, " \
                'car votre participation ' \
                "est essentielle au projet d'intégration de jeunes élèves " \
                'à la vie active'.html_safe
    @extra_content = 'Si vous souhaitez conserver votre compte, ' \
                     'connectez-vous dès maintenant.'
    @greetings = "L\'équipe 1élève1stage"
    @cta_label = 'Se connecter'
    @url       = new_user_session_url
    send_email(to: @employer.email, subject:)
  end

  def internship_application_restored_email(internship_application:)
    @internship_application = internship_application
    recipients_emails       = internship_application.filtered_notification_emails
    @internship_offer       = internship_application.internship_offer
    @employer_prez = @internship_offer.employer.presenter
    @student_prez  = internship_application.student.presenter
    @url = dashboard_internship_offer_internship_application_url(
      internship_offer_id: @internship_offer.id,
      uuid: @internship_application.uuid
    ).html_safe

    send_email(
      to: recipients_emails,
      subject: 'Une candidature été restaurée par un élève'
    )
  end
end
