class UserMailerPreview < ActionMailer::Preview
  def anonymize_user
    UserMailer.anonymize_user(recipient_email: 'hello@hoop.com')
  end

  def missing_school_manager_warning_email
    UserMailer.missing_school_manager_warning_email(
      offer: InternshipOffer.first,
      student: Users::Student.first)
  end
end
