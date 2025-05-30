# frozen_string_literal: true

class SchoolManagerMailer < ApplicationMailer
  def internship_agreement_completed_by_employer_email(internship_agreement:)
    @internship_application = internship_agreement.internship_application
    @internship_offer      = @internship_application.internship_offer
    student                = @internship_application.student
    is_public              = @internship_offer.is_public
    entreprise             = is_public ? "L'administration publique" : "L'entreprise"
    @entreprise            = "#{entreprise} #{@internship_offer.employer_name}"
    @prez_stud             = student.presenter
    @school_manager        = internship_agreement.school_management_representative
    @week                  = @internship_application.internship_offer.period
    @prez_application = Presenters::InternshipApplication.new(@internship_application, @school_manager)
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'SchoolManager - Convention To Fill In'
    ).html_safe

    to = @school_manager.try(:email)
    subject = 'Vous avez une convention de stage à renseigner.'

    send_email(to:, subject:)
  end

  def notify_others_signatures_started_email(internship_agreement:, employer:, school_management:)
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @school_manager        = school_management
    @employer              = employer
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'SchoolManager - Convention Ready to Sign'
    ).html_safe

    send_email(
      to: @school_manager.try(:email),
      subject: 'Une convention de stage est prête à être signée !'
    )
  end

  def notify_others_signatures_finished_email(internship_agreement:, employer:, school_management:)
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @school_manager        = school_management
    @employer              = internship_agreement.employer
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'SchoolManager - Convention Signed and Ready'
    ).html_safe

    send_email(
      to: @school_manager.email,
      subject: 'Dernière ligne droite pour la convention de stage'
    )
  end
end
