class EmployerMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods
  def internship_application_submitted_email
    internship_application = InternshipApplication.submitted.first

    EmployerMailer.internship_application_submitted_email(
      internship_application:
    )
  end

  def resend_internship_application_submitted_email
    internship_application = InternshipApplication.submitted.first

    EmployerMailer.resend_internship_application_submitted_email(
      internship_application:
    )
  end

  def internship_applications_reminder_email
    employer = InternshipApplication.first
                                    .internship_offer
                                    .employer
    EmployerMailer.internship_applications_reminder_email(
      employer:,
      remindable_application_ids: employer.internship_applications
    )
    # expirable_application_ids: employer.internship_applications
  end

  def internship_application_canceled_by_student_email
    internship_application = InternshipApplication&.approved&.first
    internship_application.canceled_by_student_message = "J'ai trouvé un autre stage ailleurs"
    EmployerMailer.internship_application_canceled_by_student_email(
      internship_application:
    )
  end

  def internship_application_restored_email
    internship_application = InternshipApplication&.restored&.first
    return unless internship_application

    internship_application.canceled_by_student_message = "J'ai trouvé un autre stage ailleurs"
    EmployerMailer.internship_application_canceled_by_student_email(
      internship_application:
    )
  end

  def internship_application_approved_with_agreement_email
    EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  def school_manager_finished_notice_email
    EmployerMailer.school_manager_finished_notice_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  def notify_others_signatures_started_email
    agreement = InternshipAgreement.first
    EmployerMailer.notify_others_signatures_started_email(
      internship_agreement: agreement,
      employer: agreement.employer,
      school_management: agreement.school_manager
    )
  end

  def notify_others_signatures_finished_email
    agreement = InternshipAgreement.first
    EmployerMailer.notify_others_signatures_finished_email(
      internship_agreement: agreement,
      employer: agreement.employer,
      school_management: agreement.school_manager
    )
  end

  def team_member_invitation_email
    employers = Users::Employer.all.first(2)
    team_member_invitation = TeamMemberInvitation.create(
      user: employers.first,
      invitation_email: employers.second.email
    )
    EmployerMailer.team_member_invitation_email(
      team_member_invitation,
      user: employers.second,
      current_user: employers.first
    )
  end

  def transfer_internship_application_email
    internship_application = InternshipApplication.first

    EmployerMailer.transfer_internship_application_email(
      internship_application:,
      employer_id: internship_application.employer.id,
      email: 'test@free.fr',
      message: 'This is my message to youhuhu'
    )
  end

  def cleaning_notification_email
    employer = Users::Employer.first
    EmployerMailer.cleaning_notification_email(employer.id)
  end

  def internship_application_restored_email
    internship_application = InternshipApplication.first

    EmployerMailer.internship_application_restored_email(
      internship_application:,
      employer_id: internship_application.employer.id,
      email: 'test@free.fr',
      message: 'Candidature restaurée'
    )
  end
end
