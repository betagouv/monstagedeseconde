# frozen_string_literal: true

require 'test_helper'

module Presenters
  class InternshipApplicationTest < ActiveSupport::TestCase
    test 'ok_for_restore? returns true when application is rejected' do
      employer = create(:employer)
      internship_application = create(:weekly_internship_application, :rejected)

      prez = internship_application.presenter(employer)

      assert prez.ok_for_restore?
    end

    test 'ok_for_restore? returns true when application is canceled_by_student' do
      employer = create(:employer)
      internship_application = create(
        :weekly_internship_application,
        :canceled_by_student
      )

      prez = internship_application.presenter(employer)

      assert prez.ok_for_restore?
    end

    test 'ok_for_restore? returns true when application is canceled_by_student_confirmation' do
      employer = create(:employer)
      internship_application = create(
        :weekly_internship_application,
        :canceled_by_student_confirmation
      )

      prez = internship_application.presenter(employer)

      assert prez.ok_for_restore?
    end

    test 'ok_for_restore? returns false when application is submitted' do
      employer = create(:employer)
      internship_application = create(:weekly_internship_application, :submitted)

      prez = internship_application.presenter(employer)

      refute prez.ok_for_restore?
    end

    test 'ok_for_restore? returns false when application is approved' do
      employer = create(:employer)
      internship_application = create(:weekly_internship_application, :approved)

      prez = internship_application.presenter(employer)

      refute prez.ok_for_restore?
    end
  end
end
