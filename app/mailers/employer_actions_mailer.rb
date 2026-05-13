class EmployerActionsMailer < ApplicationMailer
  include Phonable
  def digest_email(user_id:, actions:, urgency_levels:)
    @user = User.find(user_id)
    @actions = actions
    @urgency_levels = urgency_levels

    all_pending  = Array(@actions["pending_internship_application"])
    all_agreements = Array(@actions["pending_internship_agreement"])
    all_offers     = Array(@actions["pending_internship_offer"])

    # --- New applications (accept / refuse) ---
    @pending_application_rows = all_pending
      .select { |item| item.action_name == "new_internship_application" }
      .filter_map do |item|
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
          student_full_name: student_presenter.formal_name,
          age:               student_presenter.age,
          weeks:             application_presenter.date_range,
          student_email:     internship_application.student_email.presence || "Non communiqué",
          student_phone:     french_phone_number_format(internship_application.student_phone.presence) || "Non communiqué",
          school_name:       student.school.name,
          school_city:       student.school.city,
          motivation:        internship_application.motivation,
          application_url:   application_url,
          expiry_date:       expiry_date
        }
      end

    # --- Student canceled their application ---
    @canceled_by_student_rows = all_pending
      .select { |item| item.action_name == "canceled_internship_application_by_student" }
      .filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      {
        student_formal_name:  internship_application.student.presenter.formal_name,
        offer_title:          internship_application.internship_offer.title,
        cancellation_message: internship_application.canceled_by_student_message.presence
      }
    end

    # --- Student restored their application ---
    @restored_application_rows = all_pending
      .select { |item| item.action_name == "restored_internship_application" }
      .filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      {
        student_formal_name:  internship_application.student.presenter.formal_name,
        offer_title:          internship_application.internship_offer.title,
        restoration_message:  internship_application.restored_message.presence,
        application_url:      dashboard_internship_offer_internship_application_url(
          internship_application.internship_offer,
          uuid: internship_application.uuid
        )
      }
    end

    # --- Student chose another internship ---
    @chose_another_internship_rows = all_pending
      .select { |item| item.action_name == "cancel_by_student_confirmation" }
      .filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      {
        student_full_name:    internship_application.student.presenter.full_name,
        offer_title:          internship_application.internship_offer.title,
        manage_url:           dashboard_internship_offers_url
      }
    end

    # --- Application transferred to another employer ---
    @internship_application_transfered_rows = all_pending
      .select { |item| item.action_name == "internship_application_transfered" }
      .filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      {
        student_full_name: internship_application.student.presenter.full_name,
        offer_title:       internship_application.internship_offer.title,
        application_url:   dashboard_internship_offer_internship_application_url(
          internship_application.internship_offer,
          uuid: internship_application.uuid
        )
      }
    end

    # --- Agreement to sign / fill ---
    @agreement_to_sign_rows = all_agreements
      .select { |item| item.action_name == "agreement_to_sign" }
      .filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      agreement = internship_application.internship_agreement
      {
        student_full_name: internship_application.student.presenter.full_name,
        offer_title:       internship_application.internship_offer.title,
        agreement_url:     agreement ? edit_dashboard_internship_agreement_url(uuid: agreement.uuid) : dashboard_internship_offers_url
      }
    end

    # --- Signatures can start ---
    @signatures_enabled_rows = all_agreements
      .select { |item| item.action_name == "signatures_enabled" }
      .filter_map do |item|
      agreement = item.internship_agreement
      next if agreement.nil?

      internship_application = agreement.internship_application
      next if internship_application.nil?

      student = internship_application.student
      {
        student_full_name: student.presenter.full_name,
        school_name:       student.school.name,
        agreement_url:     edit_dashboard_internship_agreement_url(uuid: agreement.uuid)
      }
    end

    # --- Agreement signed by all parties ---
    @agreement_signed_by_all_rows = all_agreements
      .select { |item| item.action_name == "agreement_signed_by_all" }
      .filter_map do |item|
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

    # --- Another student's agreement was signed by all (seat taken) ---
    @agreement_signed_by_another_rows = all_agreements
      .select { |item| item.action_name == "agreement_signed_by_another" }
      .filter_map do |item|
      internship_application = item.internship_application
      next if internship_application.nil?

      student = internship_application.student
      {
        student_full_name: student.presenter.full_name,
        school_name:       student.school.name,
        offer_title:       internship_application.internship_offer.title
      }
    end

    # --- Internship offer unpublished ---
    @internship_offer_unpublished_rows = all_offers
      .select { |item| item.action_name == "internship_offer_unpublished" }
      .filter_map do |item|
      offer = item.internship_offer || item.internship_application&.internship_offer
      next if offer.nil?

      { offer_title: offer.title }
    end

    # --- Internship offer removed ---
    @internship_offer_removed_rows = all_offers
      .select { |item| item.action_name == "internship_offer_removed" }
      .filter_map do |item|
      offer = item.internship_offer || item.internship_application&.internship_offer
      next if offer.nil?

      { offer_title: offer.title }
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
