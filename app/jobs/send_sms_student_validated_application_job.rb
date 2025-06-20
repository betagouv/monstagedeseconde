# frozen_string_literal: true

class SendSmsStudentValidatedApplicationJob < ApplicationJob
  queue_as :critical

  def perform(internship_application_id:)
    internship_application = InternshipApplication.find(internship_application_id)
    url = internship_application.sgid_short_url
    phone = User.sanitize_mobile_phone_number(internship_application.student_phone, '+33')

    if phone.present?
      message = 'Votre candidature pour le stage ' \
                "chez #{internship_application.internship_offer.employer_name.truncate(60)} " \
                'a été acceptée. RDV sur 1élève1stage pour valider.'

      Services::SmsSender.new(phone_number: phone, content: message)
                         .perform
    else
      error_message = "sms [internship_application_id = #{internship_application.id}] " \
                      'to be sent with faulty phone ' \
                      "number '#{internship_application.student_phone}'!"
      Rails.logger.error(error_message)
    end
  end
end
