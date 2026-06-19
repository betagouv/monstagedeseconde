class StudentActionsMailer < ApplicationMailer
  def student_digest_email(user_id:, actions:, urgency_levels:)
    @user = Users::Student.find(user_id)
    @actions = actions
    @urgency_levels = urgency_levels

    all_applications = Array(@actions["pending_internship_application"])
    all_agreements   = Array(@actions["pending_internship_agreement"])

    sgid = @user.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s

    # --- Candidature rejetée ---
    @rejected_rows = all_applications
      .select { |item| item.action_name == "internship_application_rejected" }
      .filter_map do |item|
        application = item.internship_application
        next if application.nil?

        {
          offer_title:   application.internship_offer.title,
          employer_name: application.internship_offer.employer_name,
          search_url:    internship_offers_url
        }
      end

    # --- Candidature validée, en attente de confirmation élève ---
    @validated_rows = all_applications
      .select { |item| item.action_name == "internship_application_validated_by_employer" }
      .filter_map do |item|
        application = item.internship_application
        next if application.nil?

        {
          offer_title:      application.internship_offer.title,
          employer_name:    application.internship_offer.employer_name,
          date_range:       application.presenter(@user).date_range,
          application_url:  dashboard_students_internship_application_url(
            sgid: sgid,
            student_id: @user.id,
            uuid: application.uuid
          )
        }
      end

    # --- Candidature expirée ---
    @expired_rows = all_applications
      .select { |item| item.action_name == "internship_application_expired" }
      .filter_map do |item|
        application = item.internship_application
        next if application.nil?

        {
          offer_title:   application.internship_offer.title,
          employer_name: application.internship_offer.employer_name,
          search_url:    internship_offers_url
        }
      end

    # --- Convention à signer ---
    @agreement_to_sign_rows = all_agreements
      .select { |item| item.action_name == "agreement_to_sign" }
      .filter_map do |item|
        agreement = item.internship_agreement
        next if agreement.nil?

        application = agreement.internship_application
        next if application.nil?

        {
          offer_title:      application.internship_offer.title,
          employer_name:    application.internship_offer.employer_name,
          agreement_url:    public_internship_agreement_url(
            uuid: agreement.uuid,
            access_token: agreement.access_token.presence || ""
          )
        }
      end

    # --- Convention signée par toutes les parties ---
    @agreement_signed_by_all_rows = all_agreements
      .select { |item| item.action_name == "agreement_signed_by_all" }
      .filter_map do |item|
        agreement = item.internship_agreement
        next if agreement.nil?

        application = agreement.internship_application
        next if application.nil?

        {
          offer_title:   application.internship_offer.title,
          employer_name: application.internship_offer.employer_name,
          agreement_url: public_internship_agreement_url(
            uuid: agreement.uuid,
            access_token: agreement.access_token.presence || ""
          )
        }
      end

    send_email(to: @user.email, subject: "Résumé de vos candidatures")
  end
end
