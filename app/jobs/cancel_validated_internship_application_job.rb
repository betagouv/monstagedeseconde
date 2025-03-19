class CancelValidatedInternshipApplicationJob < ActiveJob::Base
  queue_as :default

  # Some student 'forget' about answering to offers accepted by employers.
  # They remain pending for a long time.
  # And employer does not know what to expect from student.
  # After a while, application shall expire by student not answering.

  # @param [Integer] internship_application_id
  def perform(internship_application_id:)
    internship_application = InternshipApplication.find(internship_application_id)
    return unless internship_application.validated_by_employer?

    internship_application.expire_by_student!
    StudentMailer.internship_application_expired_email(internship_application: internship_application).deliver_now
  end
end
