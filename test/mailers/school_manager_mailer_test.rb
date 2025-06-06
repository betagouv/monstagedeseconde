# frozen_string_literal: true

require 'test_helper'

class SchoolManagerMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'internship_agreement_completed_by_employer_email but no class_room' do
    internship_agreement = create(:internship_agreement, :started_by_employer)
    school_manager = internship_agreement.school_manager
    email = SchoolManagerMailer.internship_agreement_completed_by_employer_email(
      internship_agreement: internship_agreement
    )
    assert_includes email.to, school_manager.email
    assert_equal 'Vous avez une convention de stage à renseigner.', email.subject
    refute_email_spammyness(email)
  end

  test 'signatures : notify_others_signatures_started_email' do
    internship_agreement = create(:internship_agreement, :validated)
    school_manager = internship_agreement.school_manager
    email = SchoolManagerMailer.notify_others_signatures_started_email(
      internship_agreement: internship_agreement,
      employer: internship_agreement.employer,
      school_management: internship_agreement.school_management_representative
    )
    assert_includes email.to, school_manager.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

  test 'signatures : notify_others_signatures_finished_email' do
    internship_agreement = create(:internship_agreement, :validated)
    school_manager = internship_agreement.school_manager
    email = SchoolManagerMailer.notify_others_signatures_finished_email(
      internship_agreement: internship_agreement,
      employer: internship_agreement.employer,
      school_management: internship_agreement.school_management_representative
    )
    assert_includes email.to, school_manager.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end
end
