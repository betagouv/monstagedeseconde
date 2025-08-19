# frozen_string_literal: true

class TeacherMailer < ApplicationMailer
  layout 'layouts/dsfr_mailer'

  # Reminder : when approving an application, every teacher receives an email
  def internship_application_approved_with_agreement_email(internship_application:, teacher:)
    @internship_application = internship_application
    @internship_offer = internship_application.internship_offer
    @student = @internship_application.student
    @student_presenter = @student.presenter
    @url = internship_offer_url(
      id: @internship_offer.id,
      mtm_campaign: 'application-details-agreement',
      mtm_kwd: 'email'
    ).html_safe

    teachers = @student.class_room.school_managements&.teachers
    to = teachers.blank? ? nil : teachers.map(&:email)
    subject = "La candidature d'un de vos élèves a été acceptée"
    cc = @student.school_manager_email

    send_email(to:, subject:, cc:)
  end

  def internship_application_approved_with_no_agreement_email(internship_application:, teacher:)
    @teacher = teacher
    @internship_offer = internship_application.internship_offer
    @student = internship_application.student
    @student_presenter = @student.presenter
    @url = internship_offer_url(
      id: @internship_offer.id,
      mtm_campaign: 'application-details-no-agreement',
      mtm_kwd: 'email'
    ).html_safe

    @message = "Aucune convention n'est prévue sur ce site, bon stage à #{@student_presenter.civil_name} !"

    # TO DO Remove when teachers are cleaned
    teachers = @student.class_room.school_managements&.teachers
    to = teachers.blank? ? nil : teachers.map(&:email)
    subject = 'Un de vos élèves a été accepté à un stage'
    cc = nil

    send_email(to:, subject:, cc:)
  end

  def internship_application_validated_by_employer_email(internship_application)
    @teacher = internship_application&.student&.teacher
    @internship_offer = internship_application.internship_offer
    @offer_presenter = @internship_offer.presenter
    @student = internship_application.student
    @student_presenter = @student.presenter
    @week_in_words = @offer_presenter.weeks_boundaries.gsub('Du ', '')
    @url = internship_offer_url(
      id: @internship_offer.id,
      mtm_campaign: 'application-validated-by-employer',
      mtm_kwd: 'email'
    ).html_safe

    teachers = @student.class_room&.school_managements&.teachers
    to = teachers.blank? ? nil : teachers.map(&:email)
    subject = 'Un de vos élèves a été accepté en stage'
    cc = nil

    send_email(to:, subject:, cc:)
  end
end
