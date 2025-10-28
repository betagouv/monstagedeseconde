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
        createdAt: application.created_at,
        updatedAt: application.updated_at
      }
    end
  end
end