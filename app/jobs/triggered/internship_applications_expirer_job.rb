# frozen_string_literal: true

module Triggered
  class InternshipApplicationsExpirerJob < ApplicationJob
    queue_as :batches

    def perform(employer)
      internship_applications = employer.internship_applications

      return if internship_applications&.pending_for_employers.blank?

      # cache ids otherwise notifiable behaviour is changed
      expirable_application_ids = internship_applications.expirable.pluck(:id)

      update_and_expire_expirable(expirable_application_ids)
    end

    private

    def update_and_expire_expirable(ids)
      InternshipApplication.where(id: ids)
                           .each(&:expire!)
    end
  end
end
