class EmployerActionsMailer < ApplicationMailer
  include Phonable
  def digest_email(user_id:, actions:, urgency_level:)
    @user = User.find(user_id)
    @actions = actions
    @urgency_level = urgency_level

    @pending_application_rows = Array(@actions["pending_application"]).filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      internship_offer = internship_application.internship_offer
      student = internship_application.student
      student_presenter = student.presenter
      application_presenter = internship_application.presenter(internship_offer.employer)
      application_url = dashboard_internship_offer_internship_application_url(
        internship_offer,
        uuid: internship_application.uuid
      )

      expiry_date = internship_application.submitted_at
                      &.since(InternshipApplication::EXPIRATION_DURATION)
                      &.strftime("%d/%m/%Y")

      {
        student_full_name: student_presenter.full_name,
        age: student_presenter.age,
        weeks: application_presenter.date_range,
        student_email: internship_application.student_email.presence || "Non communiqué",
        student_phone: french_phone_number_format(internship_application.student_phone.presence) || "Non communiqué",
        school_name: student.school.name,
        school_city: student.school.city,
        motivation: internship_application.motivation,
        application_url: application_url,
        expiry_date: expiry_date
      }
    end

    @agreement_signed_by_all_rows = Array(@actions["agreement_signed_by_all"]).filter_map do |item|
      agreement = item.internship_agreement
      next if agreement.nil?

      internship_application = agreement.internship_application
      student = internship_application.student

      {
        student_full_name: student.presenter.full_name,
        school_name:       student.school.name,
        agreement_url:     edit_dashboard_internship_agreement_url(uuid: agreement.uuid)
      }
    end

    send_email(to: @user.email, subject: "Résumé de vos actions en attente")
  end

  private

  def french_phone_number_format(phone_number_string)
    return nil if phone_number_string.blank?

    phone_parts = phone_number_string.split("+33")
    if phone_parts.size == 2
      if phone_parts.last.start_with?("0")
        phone_number_string = phone_parts.last
      else
         phone_number_string = "0#{phone_parts.last}"
      end
    else
      phone_number_string = phone_parts.first
    end

    formatted_phone = phone_number_string.split("")
                       .each_slice(2)
                       .to_a
                       .map(&:join)
                       .join(" ")
    "+33 #{(formatted_phone)}"
  end
end
