module Api::V2
  class StudentInternshipApplicationsFormatter
    def initialize(internship_applications:)
      @internship_applications = internship_applications
    end

    def format_all
      @internship_applications.map { |application| format(application) }
    end

    private

    def format(application)
      {
        id: application.id,
        user_id: application.user_id,
        internship_offer_id: application.internship_offer_id,
        status: application.aasm_state,
        student_phone: application.student_phone,
        student_email: application.student_email,
        student_legal_representative_email: application.student_legal_representative_email,
        student_legal_representative_phone: application.student_legal_representative_phone,
        student_legal_representative_full_name: application.student_legal_representative_full_name,
        weeks: application.weeks.map { |week| week.to_s_in_api },
        createdAt: application.created_at,
        updatedAt: application.updated_at
      }
    end
  end
end