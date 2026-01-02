# frozen_string_literal: true

require 'test_helper'

module Builders
  class InternshipAgreementBuilderTest < ActiveSupport::TestCase
    test '#new_from_application with MonoInternshipAgreement' do
      student = create(:student)
      internship_offer = create(:weekly_internship_offer)
      internship_application = create(:internship_application, :approved,
                                      student: student,
                                      weeks: [internship_offer.weeks.first],
                                      internship_offer: internship_offer)
      builder = Builders::InternshipAgreementBuilder.new(user: internship_offer.employer)

      internship_agreement = builder.new_from_application(internship_application)

      assert_instance_of(InternshipAgreements::MonoInternshipAgreement, internship_agreement)
      assert_equal(student, internship_agreement.student)
      assert_equal(internship_offer, internship_agreement.internship_offer)
      assert_equal(internship_application, internship_agreement.internship_application)
    end

    test '#new_from_application with MultiInternshipAgreement' do
      student = create(:student)
      multi_corporation = create(:multi_corporation)
      internship_offer = create(:multi_internship_offer, multi_corporation: multi_corporation)
      internship_application = create(:multi_internship_application, :approved,
                                      student: student,
                                      weeks: [internship_offer.weeks.first],
                                      internship_offer: internship_offer)

      builder = Builders::InternshipAgreementBuilder.new(user: internship_offer.employer)
      internship_agreement = builder.new_from_application(internship_application)

      assert_instance_of(InternshipAgreements::MultiInternshipAgreement, internship_agreement)
      assert_equal(internship_application, internship_agreement.internship_application)
      assert_equal(internship_offer, internship_agreement.internship_offer)
      assert_equal(student, internship_agreement.student)
    end
  end
end
