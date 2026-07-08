
require 'test_helper'

class ArchiverCronJobsTest < ActiveSupport::TestCase
  # include ::EmailSpamEuristicsAssertions
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  test 'archive too old current_sign_in_at or teacher without school' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      teacher = create(:teacher)
      create(:teacher, last_sign_in_at: 3.years.ago, current_sign_in_at: Date.today - 2.years- 10.minutes)
      teacher.update_columns(class_room_id: nil, school_id: nil)
      assert_equal 2, Users::SchoolManagement.kept.reload.count
      Monstage::Application.load_tasks
      Rake::Task['cleaning:archive_idle_teachers'].invoke
      assert_equal 0, Users::SchoolManagement.kept.reload.count
      clear_enqueued_jobs
    end
  end

  test 'notify employer which offers are too old' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      too_old = 2.years.ago - 10.day
      current_week_id = Week.current.id
      more_than_2_years_ago_in_weeks = 2 * 52 + 3
      older_weeks = [Week.find(current_week_id - more_than_2_years_ago_in_weeks -1), Week.find(current_week_id - more_than_2_years_ago_in_weeks)]
      assert InternshipOffer.count.zero?
      offer = create(:weekly_internship_offer,
                   weeks: older_weeks)
      assert_equal 1, InternshipOffer.count
      refute_nil offer.last_date
      assert offer.last_date < Date.today - 2.years + 2.weeks
      assert_emails 1 do
        assert_equal 1, InternshipOffer.kept.count
        puts "tested InternshipOffer.count : #{InternshipOffer.count}"
        assert_enqueued_with job:CleaningEmployerJob, args: [offer.employer_id] do
          Monstage::Application.load_tasks
          Rake::Task['cleaning:archive_idle_employers'].invoke
        end
      end
      InternshipOfferWeek.delete_all
      InternshipOffer.delete_all
      clear_enqueued_jobs
    end
  end

  test 'do not notify employer with old offers but recent sign in' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      current_week_id = Week.current.id
      more_than_2_years_ago_in_weeks = 2 * 52 + 3
      older_weeks = [Week.find(current_week_id - more_than_2_years_ago_in_weeks - 1), Week.find(current_week_id - more_than_2_years_ago_in_weeks)]
      offer = create(:weekly_internship_offer,
                     weeks: older_weeks)
      # signed in recently -> would be spared by CleaningEmployerJob anyway, so no warning either
      offer.employer.update_columns(current_sign_in_at: 1.week.ago)
      assert_no_emails do
        assert_no_enqueued_jobs do
          Monstage::Application.load_tasks
          Rake::Task['cleaning:archive_idle_employers'].invoke
        end
      end
      # no delete_all cleanup: tests are transactional and delete_all violates
      # the internship_offer_grades FK anyway
      clear_enqueued_jobs
    end
  end

  test 'do not notify employer whose offers are not old enough at least for one' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      too_old = 2.years.ago - 10.day
      current_week_id = Week.current.id
      older_weeks = [Week.find(current_week_id - 107), Week.find(current_week_id - 106)]
      offer = create(:weekly_internship_offer,
                    weeks:older_weeks)
      create(:weekly_internship_offer, employer_id: offer.employer_id)
      assert_equal 2, InternshipOffer.kept.count
      assert_no_emails do
        assert_no_enqueued_jobs do
          Monstage::Application.load_tasks
          Rake::Task['cleaning:archive_idle_employers'].invoke
        end
      end
      InternshipOfferWeek.delete_all
      InternshipOffer.delete_all
      clear_enqueued_jobs
    end
  end

  test 'does not crash when employer has a mix of old and nil last_date offers' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      current_week_id = Week.current.id
      more_than_2_years_ago_in_weeks = 2 * 52 + 3
      older_weeks = [Week.find(current_week_id - more_than_2_years_ago_in_weeks - 1), Week.find(current_week_id - more_than_2_years_ago_in_weeks)]
      old_offer = create(:weekly_internship_offer, weeks: older_weeks)
      # second offer for same employer with nil last_date — triggered NoMethodError on nil before the fix
      create(:weekly_internship_offer, employer_id: old_offer.employer_id, last_date: nil)
      assert_equal 2, InternshipOffer.kept.count
      assert_nothing_raised do
        Monstage::Application.load_tasks
        Rake::Task['cleaning:archive_idle_employers'].invoke
      end
      InternshipOfferWeek.delete_all
      InternshipOffer.delete_all
      clear_enqueued_jobs
    end
  end
end
