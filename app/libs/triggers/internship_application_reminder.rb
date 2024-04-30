# frozen_string_literal: true

module Triggers
  # safe re-entrant code to send notifications
  class InternshipApplicationExpirer
    def enqueue_all
      Users::Employer.find_each do |employer|
        notify(employer) if notifiable?(employer)
      end
    end

    def notifiable?(employer)
      employer.internship_applications.expirable.present?
    end

    def notify(employer)
      Triggered::InternshipApplicationsExpirerJob.perform_later(employer)
    end
  end
end
