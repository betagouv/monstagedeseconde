# frozen_string_literal: true

class StudentMailer < ApplicationMailer
  def welcome_email(student:, shrinked_url:)
    @student        = student
    @shrinked_url   = shrinked_url
    @student_image  = 'boy_girl.svg'
    subject         = 'Bienvenue sur 1élève1stage'
    @welcome_phrase = 'Bienvenue sur <br/>1élève1stage'.html_safe
    @header_title = 'Vous vous êtes inscrit sur le site, mais vous ne<br/>savez pas trop ' \
                    'comment trouver un stage ?'.html_safe
    @sub_title_1 = 'Vous avez une idée de ce qui vous intéresse ?'
    @sub_title_1_content = 'Dirigez-vous sur notre site et lancez une recherche ' \
                           'avec les critères de votre choix : métier, ' \
                           "localisation, et dates de stage. N'oubliez pas : " \
                           'postuler à plusieurs offres augmente significativement ' \
                           'vos chances de succès !'
    @sub_title_2 = 'Vous ne savez pas quoi chercher?'
    @sub_title_2_content = 'Prenez un moment pour réfléchir à vos passions et ' \
                            "intérêts. Qu'est-ce qui vous anime ? Quelles matières " \
                            'vous captivent ? Discutez-en avec vos enseignants, ' \
                            'puis revenez sur notre site pour soumettre au moins ' \
                            'deux candidatures ciblées.'
    @bottom_line_phrase = '💪 Prêt à trouver le stage de vos rêves ?'
    @cta_label = "C'est parti !"
    @public_securite_image = 'securite.svg'
    @public_question_mark_image = 'question_mark.svg'
    @root_url = root_url

    send_email(to: student.email,
               specific_layout: 'welcome_mailer_layout',
               subject: subject)
  end

  def set_logo_attachment
    super
    attachments.inline['securite.svg']      = File.read("#{Rails.root}/public/assets/securite.svg")
    attachments.inline['question_mark.svg'] = File.read("#{Rails.root}/public/assets/question_mark.svg")
    attachments.inline['boy_girl.svg']      = File.read("#{Rails.root}/public/assets/boy_girl.svg")
  end

  def internship_application_approved_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: 'Une de vos candidatures a été acceptée')
  end

  def internship_application_rejected_email(internship_application:)
    @internship_application = internship_application
    @host = EmailUtils.env_host
    @url = internship_offers_url

    mail(to: @internship_application.student.email,
         subject: 'Une de vos candidatures a été refusée')
  end

  def internship_application_canceled_by_employer_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: 'Une de vos candidatures a été annulée')
  end

  def internship_application_requested_confirmation_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: 'Une de vos candidatures a été acceptée')
  end

  def internship_application_validated_by_employer_email(internship_application:)
    @internship_application = internship_application
    @student = internship_application.student
    @internship_offer = internship_application.internship_offer
    @prez_offer = @internship_offer.presenter
    @prez_student = @student.presenter
    sgid = @student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
    @url = dashboard_students_internship_application_url(
      sgid: sgid,
      student_id: @student.id,
      uuid: @internship_application.uuid
    )

    send_email(to: @student.email,
               subject: "Votre candidature a été validée par l'employeur")
  end

  def internship_application_validated_by_employer_reminder_email(applications_to_notify:)
    @internship_applications = applications_to_notify
    @internship_application = @internship_applications.last
    @plural = @internship_applications.size >= 2
    @student = applications_to_notify.first.student
    @internship_offers = applications_to_notify.map(&:internship_offer)
    @titles = @internship_offers.map(&:title)
    @prez_student = @student.presenter
    sgid = @student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
    @url = dashboard_students_internship_application_url(
      sgid: sgid,
      student_id: @student.id,
      uuid: @internship_application.uuid
    )

    send_email(to: @student.email,
               subject: "[Relance] - Candidature validée par l'employeur")
  end

  def internship_application_expired_email(internship_application:)
    @internship_application = internship_application
    @student = internship_application.student
    @internship_offer = internship_application.internship_offer
    @url = internship_offers_url
    @expiration_delay = InternshipApplication::EXPIRATION_DURATION / 1.day

    send_email(to: @student.email,
               subject: 'Votre candidature a expiré')
  end

  def single_application_reminder_email(student:)
    @subject   = 'Multipliez vos chances de trouver un stage !'
    @student   = student
    @message   = 'Envoyez trois candidatures pour augmenter vos chances de ' \
                 'trouver un stage. Cela vous permet aussi de découvrir ' \
                 'différents métiers.'

    @cta_label = 'Trouver un stage'
    @url = internship_offers_url(student.default_search_options)

    send_email(to: @student.email, subject: @subject)
  end

  def single_application_second_reminder_email(student:)
    @subject   = 'Multipliez vos chances de trouver un stage !'
    @student   = student
    @message   = 'Les employeurs peuvent prendre du temps pour répondre aux ' \
                 "candidatures. Si vous n'avez pas de nouvelles, continuez à postuler " \
                 'ailleurs. Cela maximise vos chances et vous garde actif dans ' \
                 'votre recherche de stage.'

    @cta_label = 'Trouver un stage'
    @url = internship_offers_url(student.default_search_options)

    send_email(to: @student.email, subject: @subject)
  end

  def reminder_without_application_email(student:)
    @subject   = 'Faites votre première candidature !'
    @student   = student
    @message   = "Vous n'avez pas encore postulé sur 1élève1stage ? " \
                 'Faites une recherche en indiquant le métier qui vous intéresse, ' \
                 'le lieu et la semaine de votre stage, puis proposez votre ' \
                  'candidature à plusieurs entreprises.'

    @cta_label = 'Trouver un stage'
    @url = internship_offers_url(student.default_search_options)

    send_email(to: @student.email, subject: @subject)
  end
end
