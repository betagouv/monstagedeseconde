# frozen_string_literal: true

module Triggered
  class EmployerInternshipApplicationsReminderJob < ApplicationJob
    queue_as :default

    def perform(employer)
      internship_applications = employer.internship_applications

      pending_application_ids = internship_applications.pending_for_employers.pluck(:id)

      if pending_application_ids.present?
        notify(employer: employer,
                pending_application_ids: pending_application_ids)
      end
    end

    private  

    def notify(employer:,
                pending_application_ids:)
      EmployerMailer.pending_internship_applications_reminder_email(employer: employer,
                                                              pending_application_ids: pending_application_ids)
                    .deliver_now
    end
  end
end
