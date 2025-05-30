# frozen_string_literal: true

class GodMailer < ApplicationMailer
  require_relative '../libs/email_utils'

  default from: proc { EmailUtils.formatted_from }

  def weekly_kpis_email
    kpi_reporting_service = Reporting::Kpi.new
    @last_monday = kpi_reporting_service.send(:last_monday)
    @last_sunday = kpi_reporting_service.send(:last_sunday)
    @kpis = kpi_reporting_service.last_week_kpis
    @human_date        = I18n.l Date.today,   format: '%d %B %Y'
    @human_last_monday = I18n.l @last_monday, format: '%d %B %Y'
    @human_last_sunday = I18n.l @last_sunday, format: '%d %B %Y'

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "Monitoring MS2GT : kpi du #{@human_date}"
    )
  end

  def weekly_pending_applications_email
    internship_applications = InternshipApplication.submitted
                                                   .where('submitted_at > :date', date: InternshipApplication::EXPIRATION_DURATION.ago)
                                                   .where(canceled_at: nil)

    @human_date = I18n.l Date.today, format: '%d %B %Y'

    attachment_name = 'export_candidatures_non_repondues.xlsx'
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: 'reporting/internship_applications/pending_internship_applications',
                            locals: { internship_applications: internship_applications,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = { mime_type: Mime[:xlsx], content: xlsx }

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "Monitoring MS2GT : Candidatures non répondues au #{@human_date}"
    )
  end

  def weekly_expired_applications_email
    internship_applications = InternshipApplication.expired.where('expired_at > :date', date: 15.days.ago)

    @human_date = I18n.l Date.today, format: '%d %B %Y'

    attachment_name = 'export_candidatures_expirees_depuis_15_jours.xlsx'
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: 'reporting/internship_applications/expired',
                            locals: { internship_applications: internship_applications,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = { mime_type: Mime[:xlsx], content: xlsx }

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "Monitoring MS2GT : Candidatures expirées depuis 15 jours au #{@human_date}"
    )
  end

  def employer_global_applications_reminder(employers_count)
    @human_date = I18n.l Date.today, format: '%d %B %Y'
    @employers_count = employers_count

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "#{@employers_count} employeurs relancés au #{@human_date}"
    )
  end

  def students_global_applications_reminder(students_count)
    @human_date = I18n.l Date.today, format: '%d %B %Y'
    @students_count = students_count

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "#{@students_count} élèves relancés par sms au #{@human_date}"
    )
  end

  def new_statistician_email(statistician)
    @role = statistician.role
    @statistician = statistician.presenter
    @url = root_url
    mail(
      to: ENV['MANAGER_EMAIL'],
      subject: "Inscription référent à valider : #{@statistician.full_name}"
    )
  end

  def maintenance_mailing(hash)
    @name = hash[:name]
    @subject = hash[:subject]
    @reply_to = hash[:email]
    @to = 'contact@1eleve1stage.education.gouv.fr'
    @message = hash[:message]

    send_email(to: @to,
               subject: @subject,
               reply_to: @reply_to)
  end

  def magic_link_login(user, token)
    @user = user
    @magic_link = magic_link_url(token: token)
    send_email(to: @user.email, subject: 'Votre lien de connexion sécurisé')
  end
end
