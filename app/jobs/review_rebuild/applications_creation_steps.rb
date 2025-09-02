module ReviewRebuild
  module ApplicationsCreationSteps
    include ReviewRebuild::StudentsCreationSteps
    include ReviewRebuild::OffersCreationSteps
    extend ActiveSupport::Concern

    def create_applications
      create_applications_for_troisiemes
      create_applications_for_secondes
    end

    def application_maker(student:, targeted_offer:, weeks:, aasm_state: 'submitted')
      raise StandardError, "student not found for student #{student.id}" if student.nil?
      raise StandardError, "offer not found for student #{student.id}" if targeted_offer.nil?

      unless targeted_offer.grades.include?(student.grade)
        raise StandardError,
              "grades differ for student #{student.email} and offer: ##{targeted_offer.id}"
      end

      internship_application = student.internship_applications.build(
        internship_offer: targeted_offer,
        week_ids: weeks.map(&:id),
        motivation: FFaker::Lorem.sentence(10),
        student_email: student.email,
        student_phone: student.phone,
        skip_callback_with_review_rebuild: true
      )

      unless internship_application.valid?
        message_box.broadcast_info(message_content: internship_application.errors.full_messages.to_sentence,
                                   time_value: 0)
      end
      internship_application.save!
      if aasm_state == :submitted
        internship_application.update_columns(aasm_state: 'submitted', submitted_at: rand(3..10).days.ago)
      end
      internship_application
    end

    # Logic for creating applications for 3eme
    def create_applications_for_troisiemes
      student = college_qpv_students.first
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      # just submitted
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.first]
      )
      # -----------
      student = college_standard_students.first
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      # --- end of submitted

      student = college_qpv_students.second
      targeted_offer = paris_offers.troisieme_or_quatrieme.second
      # approved
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.first]
      )
      college_qpv_students[5..12].each do |stu|
        application_maker(
          student: stu,
          targeted_offer: targeted_offer,
          weeks: [targeted_offer.weeks.first]
        )
      end
      approve_applications(InternshipApplication.order(created_at: :desc).first(3))
      # -----------
      student = college_standard_students.second
      targeted_offer = paris_offers.troisieme_or_quatrieme.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      # end of approved ----
      # --- rejected
      student = college_qpv_students.third
      targeted_offer = paris_offers.troisieme_or_quatrieme.published.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      student = college_standard_students.third
      targeted_offer = paris_offers.troisieme_or_quatrieme.published.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      InternshipApplication.last(2).each { |app| app.reject! }
    end

    # Logic for creating applications for 2de
    def create_applications_for_secondes
      student = lycee_qpv_students.first
      targeted_offer = paris_offers.seconde.first
      # just submitted
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.first]
      )
      # -----------
      student = lycee_standard_students.first
      targeted_offer = paris_offers.seconde.second
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      # --- end of submitted

      student = lycee_qpv_students.second
      targeted_offer = paris_offers.seconde.second
      # approved
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.first]
      )
      lycee_qpv_students[5..12].each do |stu|
        application_maker(
          student: stu,
          targeted_offer: targeted_offer,
          weeks: [targeted_offer.weeks.first]
        )
      end
      approve_applications(InternshipApplication.order(created_at: :desc).first(3))
      # -----------
      student = lycee_standard_students.second
      targeted_offer = paris_offers.seconde.last
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )

      # end of approved ----
      # --- rejected
      student = lycee_qpv_students.third
      targeted_offer = paris_offers.seconde.published.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      student = lycee_standard_students.third
      targeted_offer = paris_offers.seconde.published.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [targeted_offer.weeks.second]
      )
      InternshipApplication.last(2).each { |app| app.reject! }
    end

    # -- helpers

    def first_week_seconde
      SchoolTrack::Seconde.first_week
    end

    def second_week_seconde
      SchoolTrack::Seconde.second_week
    end

    def both_weeks_seconde
      [first_week_seconde, second_week_seconde]
    end

    def all_year_long
      SchoolTrack::Troisieme.selectable_on_school_year_weeks.to_a
    end

    def all_weeks
      both_weeks_seconde + all_year_long
    end

    def from_now_to_end_of_current_troisieme_year_limits
      SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year
    end

    def paris_offers
      InternshipOffers::WeeklyFramed.where(city: 'Paris')
    end

    def approve_applications(arr)
      arr.each do |app|
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!
        app.approve!
        app.update_columns(
          approved_at: rand(0..2).days.ago,
          validated_by_employer_at: rand(3..5).days.ago,
          submitted_at: rand(6..10).days.ago
        )
      end
    end
  end
end
