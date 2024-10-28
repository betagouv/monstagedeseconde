# frozen_string_literal: true

require 'test_helper'
module Users
  class StudentTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'student.after_sign_in_path redirects to new_session_path' do
      student = create(:student)
      assert_equal(student.after_sign_in_path,
                   Rails.application.routes.url_helpers.internship_offers_path(student.default_search_options),
                   'failed to use default_internship_offers_path for user without targeted_offer_id')

      student.targeted_offer_id = 1
      assert_equal(student.after_sign_in_path,
                   Rails.application.routes.url_helpers.internship_offer_path(id: 1))
    end

    test 'validate wrong mobile phone format' do
      user = build(:student, phone: '+330111223344')
      refute user.valid?
      assert_equal ['Veuillez modifier le numéro de téléphone mobile'], user.errors.messages[:phone]
    end

    test 'validate wrong phone format' do
      user = build(:student, phone: '06111223344')
      refute user.valid?
      assert_equal ['Veuillez modifier le numéro de téléphone mobile'], user.errors.messages[:phone]
    end

    test 'validate good phone format' do
      user = build(:student, phone: '+330611223344')
      assert user.valid?
    end

    test 'no phone token creation after user creation' do
      user = create(:student, phone: '')
      assert_nil user.phone_token
      assert_nil user.phone_token_validity
    end

    test '#main_teacher' do
      school                     = create(:school)
      school_with_school_manager = create(:school, :with_school_manager)

      student_no_class_room = build(:student, class_room: nil)
      assert_nil student_no_class_room.class_room
      assert_nil student_no_class_room.main_teacher

      class_room = create(:class_room, school:)
      student_with_class_room = build(:student, class_room:)
      assert_nil student_with_class_room.main_teacher

      main_teacher   = create(:main_teacher, class_room:, school: school_with_school_manager)
      main_teacher_2 = create(:main_teacher, class_room:, school: school_with_school_manager)
      student        = create(:student, class_room:, school: school_with_school_manager)
      assert_equal main_teacher.id, student.main_teacher.id
    end

    test '#has_offers_to_apply_to?' do
      travel_to Date.new(2024, 9, 1) do
        weeks_till_end = Week.selectable_from_now_until_end_of_school_year
        school         = create(:school, :with_school_manager)
        student        = create(:student, :troisieme, school:)
        refute student.has_offers_to_apply_to?
        create(:weekly_internship_offer_3eme, coordinates: Coordinates.bordeaux)
        refute student.has_offers_to_apply_to?
        create(:weekly_internship_offer_3eme, coordinates: Coordinates.paris)
        assert student.has_offers_to_apply_to?
      end
    end

    test 'reminders are set after creation' do
      assert_enqueued_jobs 1, only: SendReminderToStudentsWithoutApplicationJob do
        student = create(:student)
      end
    end

    test '#other_approved_applications_compatible? context: no application, student tries to apply to an offer with a both weeks period' do
      student = create(:student, :seconde)
      internship_offer = create(:weekly_internship_offer_2nde, :both_weeks)
      assert student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 approved application week 1, student tries to apply to an offer with a both weeks period' do
      student = create(:student)
      internship_offer_week_1 = create(:weekly_internship_offer_2nde, :week_1)
      create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_week_1)
      internship_offer = create(:weekly_internship_offer_2nde, :both_weeks)
      refute student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 approved application week 2, student tries to apply to an offer with a both weeks period' do
      student = create(:student, :seconde)
      internship_offer_week_2 = create(:weekly_internship_offer_2nde, :week_2)
      create(:weekly_internship_application, :approved, student:,
                                                        week: internship_offer_week_2.weeks.first,
                                                        internship_offer: internship_offer_week_2)
      internship_offer = create(:weekly_internship_offer_2nde, :both_weeks)
      refute student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 approved application both weeks, student tries to apply to an offer with a both weeks period' do
      internship_offer_full_time = create(:weekly_internship_offer_2nde, :both_weeks)
      internship_application = create(:weekly_internship_application, :approved, :both_june_weeks,
                                      internship_offer: internship_offer_full_time)
      internship_offer = create(:weekly_internship_offer_2nde, :both_weeks)
      refute internship_application.student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: no application, student tries to apply to an offer with a week_1 period' do
      student = create(:student, :seconde)
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      assert student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 approved application week 1, student tries to apply to an offer with a week_1 period' do
      student = create(:student, :seconde)
      internship_offer_week_1 = create(:weekly_internship_offer_2nde, :week_1)
      create(:weekly_internship_application, :approved, student:,
                                                        internship_offer: internship_offer_week_1,
                                                        week: internship_offer_week_1.weeks.first)
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      refute student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 approved application week 2, student tries to apply to an offer with a week_1 period' do
      student = create(:student, :seconde)
      internship_offer_week_2 = create(:weekly_internship_offer_2nde, :week_2)
      create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_week_2,
                                                        week: internship_offer_week_2.weeks.first)
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      assert student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 approved application both weeks, student tries to apply to an offer with a week_1 period ' do
      student = create(:student)
      internship_offer_full_time = create(:weekly_internship_offer_2nde, :both_weeks)
      create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_full_time)
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      refute student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#other_approved_applications_compatible? context: 1 *submitted* application both weeks, student tries to apply to an offer with a week_1 period ' do
      student = create(:student, :seconde)
      internship_offer_full_time = create(:weekly_internship_offer_2nde, :both_weeks)
      create(:weekly_internship_application, :submitted, student:, internship_offer: internship_offer_full_time)
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      assert student.other_approved_applications_compatible?(internship_offer:)
    end

    test '#with_2_weeks_internships_approved? context: no approved application' do
      student = create(:student, :seconde)
      internship_offer_full_time = create(:weekly_internship_offer_2nde, :both_weeks)
      create(:weekly_internship_application, :submitted, student:, internship_offer: internship_offer_full_time)
      refute student.with_2_weeks_internships_approved?
    end

    test '#with_2_weeks_internships_approved? context: a 1 week approved application' do
      student = create(:student, :seconde)
      internship_offer_week_1 = create(:weekly_internship_offer_2nde, :week_1)
      create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_week_1)
      refute student.with_2_weeks_internships_approved?
    end

    test '#with_2_weeks_internships_approved? context: a 2 weeks approved application' do
      student = create(:student, :seconde)
      internship_offer_full_time = create(:weekly_internship_offer_2nde, :both_weeks)
      create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_full_time)
      assert student.with_2_weeks_internships_approved?
    end

    test '#with_2_weeks_internships_approved? context: 2 weeks different weeks approved application' do
      travel_to Date.new(2023, 9, 1) do
        student = create(:student, :seconde, phone: '+330612345678')
        internship_offer_week_1 = create(:weekly_internship_offer_2nde, :week_1)
        internship_offer_week_2 = create(:weekly_internship_offer_2nde, :week_2)
        create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_week_1)
        create(:weekly_internship_application, :approved, student:, internship_offer: internship_offer_week_2)
        assert student.with_2_weeks_internships_approved?
      end
    end
  end
end
