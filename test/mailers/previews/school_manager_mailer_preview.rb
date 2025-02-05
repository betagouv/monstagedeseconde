class SchoolManagerMailerPreview < ActionMailer::Preview
  def notify_others_signatures_started_email
    SchoolManagerMailer.notify_others_signatures_started_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  def notify_others_signatures_finished_email
    SchoolManagerMailer.notify_others_signatures_finished_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  def notify_school_manager_of_employer_completion_email
    SchoolManagerMailer.internship_agreement_completed_by_employer_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  private

  def school_manager
    Users::SchoolManagement.find_by(role: 'school_manager')
  end

  def fetch_teacher
    Users::SchoolManagement.find_by(role: 'teacher')
  end
end
