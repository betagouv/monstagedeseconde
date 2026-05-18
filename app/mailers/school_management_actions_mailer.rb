class SchoolManagementActionsMailer < ApplicationMailer
  include Phonable
  def school_management_digest_email(user_id:, actions:, urgency_levels:)
    @user = User.find(user_id)
    @actions = actions
    @urgency_levels = urgency_levels
    @recipient_name = @user.try(:presenter).try(:formal_name).presence || @user.try(:name)

    all_agreements = Array(@actions["pending_internship_agreement"])

    @agreement_completed_by_employer_rows = all_agreements
      .select { |item| item.action_name == "internship_agreement_completed_by_employer" }
      .filter_map do |item|
      agreement = item.internship_agreement || item.internship_application&.internship_agreement
      next if agreement.nil?

      internship_application = agreement.internship_application
      next if internship_application.nil?

      internship_offer = internship_application.internship_offer
      student = internship_application.student

      {
        student_full_name: student.presenter.full_name,
        employer_name: internship_offer.employer_name,
        offer_title: internship_offer.title,
        weeks: agreement.date_range,
        agreement_url: edit_dashboard_internship_agreement_url(uuid: agreement.uuid)
      }
    end

    @signatures_enabled_rows = all_agreements
      .select { |item| item.action_name == "signatures_enabled" }
      .filter_map do |item|
      agreement = item.internship_agreement || item.internship_application&.internship_agreement
      next if agreement.nil?

      internship_application = agreement.internship_application
      next if internship_application.nil?

      student = internship_application.student
      internship_offer = internship_application.internship_offer

      {
        student_full_name: student.presenter.full_name,
        employer_name: internship_offer.employer_name,
        offer_title: internship_offer.title,
        agreement_url: edit_dashboard_internship_agreement_url(uuid: agreement.uuid)
      }
    end

    @agreement_signed_by_all_rows = all_agreements
      .select { |item| item.action_name == "agreement_signed_by_all" }
      .filter_map do |item|
      agreement = item.internship_agreement || item.internship_application&.internship_agreement
      next if agreement.nil?

      internship_application = agreement.internship_application
      next if internship_application.nil?

      student = internship_application.student
      internship_offer = internship_application.internship_offer

      {
        student_full_name: student.presenter.full_name,
        employer_name: internship_offer.employer_name,
        offer_title: internship_offer.title,
        agreement_url: edit_dashboard_internship_agreement_url(uuid: agreement.uuid)
      }
    end

    send_email(to: @user.email, subject: "Résumé de vos actions en attente")
  end

  alias employer_digest_email school_management_digest_email
end
