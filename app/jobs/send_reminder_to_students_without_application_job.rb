# frozen_string_literal: true

class SendReminderToStudentsWithoutApplicationJob < ApplicationJob
  queue_as :default

  def perform(student_id)
    student = Users::Student.find(student_id)
    return unless student.internship_applications.empty?
    
    if student.email.blank?
        # Send SMS
        return if student.phone.blank?
        phone = student.phone
        content = "Faites votre première candidature et trouvez votre stage \
                    sur Mon stage de seconde. L'équpe de Mon Stage de seconde"

        SendSmsJob.perform_later(user: student, message: content)
    else
        # Send email
        StudentMailer.reminder_without_application_email(student: student).deliver_later
    end
  end
end
  
 