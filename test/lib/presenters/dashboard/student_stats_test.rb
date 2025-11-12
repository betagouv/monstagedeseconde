# frozen_string_literal: true

require 'test_helper'

module Presenters
  module Dashboard
    class StudentStatsTest < ActiveSupport::TestCase
      setup do
        @student = create(:student, phone: '+330612345678')
        @student_stats = StudentStats.new(student: @student)
      end

      test '.applications_count' do
        another_student = create(:student)
        create(:weekly_internship_application, student: another_student)
        create(:weekly_internship_application, student: @student)
        assert_equal 1, @student_stats.applications_count
      end

      test '.applications_approved_count' do
        create(:weekly_internship_application, :rejected, student: @student)
        create(:weekly_internship_application, :approved, student: @student)
        assert_equal 1, @student_stats.applications_approved_count
      end

      test '.internship_location' do
        internship_offer = create(:weekly_internship_offer_2nde, street: '7 rue du puits',
                                                                 city: 'Coye la foret',
                                                                 zipcode: '60580')
        create(:weekly_internship_application,
               :approved,
               student: @student,
               internship_offer:)
        assert_equal [internship_offer.formatted_autocomplete_address],
                     @student_stats.internship_locations
      end

      test '.applications_best_status' do
        student = create(:student)
        assert_equal({ color: 'warning', label: 'doit faire des candidatures' },
                     @student_stats.applications_best_status)
        create(:weekly_internship_application, :expired, student: student)
        assert_equal({ color: 'error ', label: 'candidature expirée' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_student_confirmation, student: student)
        assert_equal({ color: 'error', label: 'candidature annulée par l\'élève' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_student, student: student)
        assert_equal({ color: 'error', label: 'candidature annulée par l\'élève' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :expired_by_student, student: student)
        assert_equal({ color: 'error', label: 'candidature non retenue' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :rejected, student: student)
        assert_equal({ color: 'error', label: 'candidature non retenue' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_employer, student: student)
        assert_equal({ color: 'error', label: 'candidature non retenue' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :submitted, student: student)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :expired, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_student_confirmation, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_student, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :expired_by_student, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :rejected, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :canceled_by_employer, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :submitted, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :read_by_employer, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, student:)
        assert_equal({ color: 'info', label: 'en attente de réponse' },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :validated_by_employer, student:)
        assert_equal({ color: 'new', label: "confirmer la venue dans l'entreprise" },
                     StudentStats.new(student: student.reload).applications_best_status)
        create(:weekly_internship_application, :approved, student:)
        assert_equal({ color: 'success', label: 'stage accepté' },
                     StudentStats.new(student: student.reload).applications_best_status)
      end
    end
  end
end
