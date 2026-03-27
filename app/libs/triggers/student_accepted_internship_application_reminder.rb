# frozen_string_literal: true

module Triggers
  # safe re-entrant code to send notifications
  class StudentAcceptedInternshipApplicationReminder
    REMINDER_DAYS = 2

    def enqueue_all
      Users::Student.find_each do |student|
        notify(student) if notifiable?(student)
      end
    end

    private

    def reminder_threshold
      REMINDER_DAYS.days.ago
    end

    def pending_validated_applications(student)
      student.internship_applications
             .where(aasm_state: :validated_by_employer)
             .where('DATE(validated_by_employer_at) <= ?', reminder_threshold.to_date)
             .to_a
    end

    def notifiable?(student)
      return false if student.internship_applications.any?(&:approved?)

      pending_validated_applications(student).count.positive?
    end

    def notify(student)
      StudentMailer.internship_application_validated_by_employer_reminder_email(
        applications_to_notify: pending_validated_applications(student)
      ).deliver_later(wait: 1.second)
    end
  end
end
