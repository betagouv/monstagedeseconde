# frozen_string_literal: true

class TeacherMailerPreview < ActionMailer::Preview
  def internship_application_approved_with_agreement_email
    internship_application = InternshipApplication&.approved&.first

    TeacherMailer.internship_application_approved_with_agreement_email(
      internship_application: internship_application,
      teacher: fetch_teacher(internship_application)
    )
  end

  def internship_application_approved_with_no_agreement_email
    internship_application = InternshipApplication&.approved&.first

    TeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      teacher: fetch_teacher(internship_application)
    )
  end

  def internship_application_approved_with_no_agreement_email
    internship_application = InternshipApplication&.approved&.first

    TeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      teacher: fetch_teacher(internship_application)
    )
  end

  def internship_application_validated_by_employer_email
    internship_application = InternshipApplication&.approved&.first

    TeacherMailer.internship_application_validated_by_employer_email( internship_application )
  end

  private

  def fetch_teacher(internship_application)
    school = internship_application.student.school
    return school.teachers.first if school.teachers.present?
  end

end
