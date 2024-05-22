module Triggered
  class StudentExpiredInternshipApplicationsNotificationJob < ApplicationJob
    queue_as :default
   
    def perform(internship_application)
      StudentMailer.internship_application_expired_email(internship_application: internship_application).deliver_now
    end
  end
end
