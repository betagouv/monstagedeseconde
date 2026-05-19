# frozen_string_literal: true

class GodMailer < ApplicationMailer
  require_relative "../libs/email_utils"

  default from: proc { EmailUtils.formatted_from }

  def weekly_kpis_email
    kpi_reporting_service = Reporting::Kpi.new
    @last_monday = kpi_reporting_service.send(:last_monday)
    @last_sunday = kpi_reporting_service.send(:last_sunday)
    @kpis = kpi_reporting_service.last_week_kpis
    @human_date        = I18n.l Date.today,   format: "%d %B %Y"
    @human_last_monday = I18n.l @last_monday, format: "%d %B %Y"
    @human_last_sunday = I18n.l @last_sunday, format: "%d %B %Y"
    @recipient_email = ENV.fetch("TEAM_DSI_EMAIL", "1e1s_team@free.fr")

    mail(
      to: @recipient_email,
      subject: "Monitoring 1E1S : kpi du #{@human_date}"
    )
  end

  def weekly_pending_applications_email
    internship_applications = InternshipApplication.submitted
                                                   .where("submitted_at > :date", date: InternshipApplication::EXPIRATION_DURATION.ago)
                                                   .where(canceled_at: nil)

    @human_date = I18n.l Date.today, format: "%d %B %Y"

    attachment_name = "export_candidatures_non_repondues.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [ :axlsx ],
                            formats: [ :xlsx ],
                            template: "reporting/internship_applications/pending_internship_applications",
                            locals: { internship_applications: internship_applications,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = { mime_type: Mime[:xlsx], content: xlsx }

    mail(
      to: ENV["TEAM_EMAIL"],
      subject: "Monitoring MS2GT : Candidatures non répondues au #{@human_date}"
    )
  end

  def weekly_expired_applications_email
    internship_applications = InternshipApplication.expired.where("expired_at > :date", date: 15.days.ago)

    @human_date = I18n.l Date.today, format: "%d %B %Y"

    attachment_name = "export_candidatures_expirees_depuis_15_jours.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [ :axlsx ],
                            formats: [ :xlsx ],
                            template: "reporting/internship_applications/expired",
                            locals: { internship_applications: internship_applications,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = { mime_type: Mime[:xlsx], content: xlsx }

    mail(
      to: ENV["TEAM_EMAIL"],
      subject: "Monitoring MS2GT : Candidatures expirées depuis 15 jours au #{@human_date}"
    )
  end

  def employer_global_applications_reminder(employers_count)
    @human_date = I18n.l Date.today, format: "%d %B %Y"
    @employers_count = employers_count

    mail(
      to: ENV["TEAM_EMAIL"],
      subject: "#{@employers_count} employeurs relancés au #{@human_date}"
    )
  end

  def students_global_applications_reminder(students_count)
    @human_date = I18n.l Date.today, format: "%d %B %Y"
    @students_count = students_count

    mail(
      to: ENV["TEAM_EMAIL"],
      subject: "#{@students_count} élèves relancés par sms au #{@human_date}"
    )
  end

  def new_statistician_email(statistician)
    @role = statistician.role
    @statistician = statistician.presenter
    @url = root_url
    mail(
      to: ENV["MANAGER_EMAIL"],
      subject: "Inscription référent à valider : #{@statistician.full_name}"
    )
  end

  def maintenance_mailing(hash)
    @name = hash[:name]
    @subject = hash[:subject]
    @reply_to = hash[:email]
    @to = "contact@1eleve1stage.education.gouv.fr"
    @message = hash[:message]

    send_email(to: @to,
               subject: @subject,
               reply_to: @reply_to)
  end

  def magic_link_login(user, token)
    @user = user
    @magic_link = magic_link_url(token: token)
    send_email(to: @user.email, subject: "Votre lien de connexion sécurisé")
  end

  def export_offers_department(department_code:, offers_count:, csv_data:, filename:)
    @department_code = department_code
    @offers_count = offers_count
    @filename = filename

    attachments[filename] = { mime_type: "text/csv", content: csv_data }

    send_email(
      to: ENV["TEAM_EMAIL"],
      subject: "Export offres préfixe postal #{department_code} - #{Date.current.strftime('%d/%m/%Y')}"
    )
  end

  def notify_others_signatures_started_email(
    internship_agreement:,
    missing_signatures_recipients:,
    last_signature:
  )
    @internship_agreement  = internship_agreement
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = internship_agreement.employer
    @school_manager        = internship_agreement
                              .school_management_representative
    @last_signature        = last_signature
    @last_signature_role   = format_signature_role(last_signature)
    @url = dashboard_internship_agreements_url(
      uuid: internship_agreement.uuid
    ).html_safe

    email_recipients = handle_school_manager_mail_action(
      internship_agreement: internship_agreement,
      action_name: "agreement_to_sign",
      email_recipients: missing_signatures_recipients.dup,
      school_manager: @school_manager
    )

    send_email(
      to: email_recipients,
      subject: "Une convention de stage attend votre signature"
    )
  end

  def notify_others_signatures_finished_email(internship_agreement:)
    @internship_agreement  = internship_agreement
    @school_manager        = internship_agreement.school_manager
    internship_application = internship_agreement.internship_application
    student                = internship_application.student
    @internship_offer      = internship_application.internship_offer
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    recipients_email       = recipients_email_for_signature(
      internship_agreement: internship_agreement
    )
    @url = dashboard_internship_agreements_url(
      uuid: internship_agreement.uuid
    ).html_safe

    email_recipients = recipients_email - [ @internship_offer.employer.email ]
    email_recipients = handle_school_manager_mail_action(
      internship_agreement: internship_agreement,
      action_name: "agreement_signed_by_all",
      email_recipients: email_recipients,
      school_manager: @school_manager
    )

    send_email(
      to: email_recipients,
      subject: "Une convention de stage est signée par tous"
    )
  end

  def notify_signatures_can_start_email(internship_agreement:)
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    employer               = @internship_offer.employer
    # employer is notified by digest email when the agreement is ready,
    # so we exclude them from this email to avoid sending two emails at the same time
    recipients_email       = recipients_email_for_signature(
      internship_agreement: internship_agreement
    ) - [ employer.email ]
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @school_manager        = internship_agreement.school_manager
    @url = dashboard_internship_agreements_url(
      uuid: internship_agreement.uuid
    ).html_safe

    recipients_email = handle_school_manager_mail_action(
      internship_agreement: internship_agreement,
      action_name: "signatures_enabled",
      email_recipients: recipients_email,
      school_manager: @school_manager
    )

    handle_student_mail_action(
      internship_agreement: internship_agreement,
      student: student,
      email_recipients: recipients_email
    )

    send_email(
      to: recipients_email,
      subject: "Imprimez et signez la convention de stage."
    )
  end

  def notify_student_legal_representatives_can_sign_email(internship_agreement:, representative:)
    internship_application = internship_agreement.internship_application
    recipients_email       = legal_representatives_emails(internship_agreement)
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @school_manager        = internship_agreement.school_manager

    Rails.logger.info("no representatives found for notify_student_legal_representatives_can_sign_email") if recipients_email.empty?

    @url = public_internship_agreement_url(
      uuid: internship_agreement.uuid,
      access_token: internship_agreement.access_token || "",
      student_legal_representative_nr: representative[:nr]
    ).html_safe
    send_email(
      to: representative[:email],
      subject: "Imprimez et signez la convention de stage."
    )
  end

  def offer_was_flagged(inappropriate_offer)
    @inappropriate_offer = inappropriate_offer
    @internship_offer = inappropriate_offer.internship_offer
    @fr_ground = InappropriateOffer.options_for_ground[@inappropriate_offer.ground.to_s]
    @user = inappropriate_offer.user
    moderation_emails = parse_email_list(ENV["MODERATION_TEAM_EMAIL"])
    send_email(
      to: moderation_emails,
      subject: "Offre signalée : [#{@fr_ground}] - #{@internship_offer.title} (##{@inappropriate_offer.id})"
    )
  end

  private

  def recipients_email_for_signature(internship_agreement:, with_legal_representatives: true)
    internship_application = internship_agreement.internship_application
    student                = internship_application.student
    recipients_email       = internship_application.employers_filtered_by_notifications_emails
    recipients_email << student.email
    recipients_email += legal_representatives_emails(internship_agreement) if with_legal_representatives
    recipients_email << internship_agreement.school_management_representative.email

    recipients_email.compact.uniq
  end

  def legal_representatives_emails(internship_agreement)
    internship_agreement.legal_representative_data.values.map { |rep| rep[:email] }.compact.uniq
  end

  def format_signature_role(signature)
    return nil if signature.nil?

    key = "activerecord.attributes.signature.signatory_role.#{signature.signatory_role.downcase}"
    I18n.t(key)
  end

  def handle_school_manager_mail_action(
    internship_agreement:,
    action_name:,
    email_recipients:,
    school_manager:
  )
    school_roles_not_signed = internship_agreement.roles_not_signed_yet &
                              Signature::SCHOOL_MANAGEMENT_SIGNATORY_ROLE

    if school_roles_not_signed.any? && school_manager.present?
      MailActionItem.create_by_name!(
        action_name,
        recipient: school_manager,
        internship_agreement: internship_agreement
      )
      return email_recipients - [ school_manager.email ]
    end

    email_recipients
  end

  def handle_student_mail_action(internship_agreement:, student:, email_recipients:)
    return if student.email.blank?

    stale_at = internship_agreement.internship_application
                                   .weeks
                                   &.order(:year, :number)
                                   &.last
                                   &.monday || 30.days.from_now
    MailActionItem.create_by_name!(
      "agreement_to_sign",
      recipient: student,
      internship_agreement_id: internship_agreement.id,
      internship_application_id: internship_agreement.internship_application.id,
      stale_at: stale_at
    )
    email_recipients - [ student.email ]
  end

  def parse_email_list(email_string)
    return [] if email_string.blank?

    email_string.split(/[,;\s\n]+/)
                .map(&:strip)
                .reject(&:blank?)
                .uniq
  end
end
