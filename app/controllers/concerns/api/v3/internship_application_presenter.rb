# frozen_string_literal: true

module Api
  module V3
    module InternshipApplicationPresenter
      extend ActiveSupport::Concern

      private

      def internship_application_payload(internship_application)
        {
          id: internship_application.id,
          uuid: internship_application.uuid,
          internship_offer_id: internship_application.internship_offer_id,
          student_id: internship_application.user_id,
          state: internship_application.aasm_state,
          submitted_at: internship_application.submitted_at&.iso8601,
          motivation: internship_application.motivation,
          student_phone: internship_application.student_phone,
          student_email: internship_application.student_email,
          student_address: internship_application.student_address,
          student_legal_representative_full_name: internship_application.student_legal_representative_full_name,
          student_legal_representative_email: internship_application.student_legal_representative_email,
          student_legal_representative_phone: internship_application.student_legal_representative_phone,
          employer_name: internship_application.internship_offer.employer_name,
          internship_offer_title: internship_application.internship_offer.title,
          internship_offer_address: internship_application.presenter(internship_application.student).internship_offer_address,
          weeks: internship_application.weeks.map do |week|
            {
              id: week.id,
              label: week.human_select_text_method,
              selected: internship_application.week_ids&.include?(week.id)
            }
          end,
          created_at: internship_application.created_at.iso8601,
          updated_at: internship_application.updated_at.iso8601
        }
      end

      def internship_application_form_payload(user:, weeks:)
        {
          id: 'new',
          student_phone: user.phone,
          student_email: user.email,
          representative_full_name: user.legal_representative_full_name,
          representative_email: user.legal_representative_email,
          representative_phone: user.legal_representative_phone,
          motivation: '',
          weeks: weeks
        }
      end
    end
  end
end

