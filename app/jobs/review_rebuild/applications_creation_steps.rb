module ReviewRebuild
  module ApplicationsCreationSteps
    include ReviewRebuild::StudentsCreationSteps
    include ReviewRebuild::OffersCreationSteps
    extend ActiveSupport::Concern

    def create_applications
      create_applications_for_troisiemes
      create_applications_for_secondes
    end

    def application_maker(student:, targeted_offer:, weeks:, aasm_state: "submitted")
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
        internship_application.update_columns(aasm_state: "submitted", submitted_at: rand(3..10).days.ago)
      end
      internship_application
    rescue StandardError => e
      message_box.broadcast_info(message_content: "Error for student #{student&.email || 'unknown'} and offer ##{targeted_offer&.id || 'unknown'}: #{e.message}",
                                 time_value: 0)
    end

    # Logic for creating applications for 3eme
    def create_applications_for_troisiemes
      student = college_qpv_students.first
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      # just submitted
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_offer.weeks.first ]
      )
      # -----------
      student = college_standard_students.first
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_offer.weeks.second ]
      )
      # --- end of submitted

      student_2 = college_qpv_students.second
      targeted_offer_2 = paris_offers.troisieme_or_quatrieme.second
      # approved
      application_maker(
        student: student_2,
        targeted_offer: targeted_offer_2,
        weeks: [ targeted_offer_2.weeks.first ]
      )
      raise "that's it" if student.id.in?(college_qpv_students[5..12].map(&:id))
      raise "that's it 2" if student_2.id.in?(college_qpv_students[5..12].map(&:id))

      college_qpv_students[5..12].each do |stu|
        application_maker(
          student: stu,
          targeted_offer: targeted_offer_2,
          weeks: [ targeted_offer.weeks.first ]
        )
      end
      approve_applications(InternshipApplication.order(id: :desc).first(4))
      # -----------
      student = college_standard_students.second
      targeted_offer = paris_offers.troisieme_or_quatrieme.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_offer.weeks.second ]
      )
      # end of approved ----
      # --- rejected
      student = college_qpv_students.third
      targeted_offer = paris_offers.troisieme_or_quatrieme.published.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_offer.weeks.second ]
      )
      student = college_standard_students.third
      targeted_offer = paris_offers.troisieme_or_quatrieme.published.third
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_offer.weeks.second ]
      )
      InternshipApplication.last(2).each { |app| app.reject! }
      # --- end of rejected

      # --- read_by_employer
      student = college_rep_active_students.first
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.read!(Users::God.first)
      end
      # --- end of read_by_employer

      # --- transfered
      student = college_rep_active_students.second
      targeted_offer = paris_offers.troisieme_or_quatrieme.second
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.transfer!(Users::God.first)
        app.update_columns(transfered_at: rand(3..7).days.ago)
      end
      # --- end of transfered

      # --- validated_by_employer (en attente de confirmation élève)
      student = college_rep_active_students.third
      targeted_offer = paris_offers.troisieme_or_quatrieme.second
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.second ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!(Users::God.first)
        app.update_columns(validated_by_employer_at: rand(2..4).days.ago)
      end
      # --- end of validated_by_employer

      # --- canceled_by_employer (offer was approved then cancelled by employer)
      student = college_rep_active_students[3]
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!(Users::God.first)
        app.approve!(Users::God.first)
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_employer!(Users::God.first)
        app.update_columns(canceled_at: rand(1..3).days.ago)
      end
      # --- end of canceled_by_employer

      # --- canceled_by_student
      student = college_rep_active_students[4]
      targeted_offer = paris_offers.troisieme_or_quatrieme.third
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_student!(Users::God.first)
        app.update_columns(canceled_at: rand(1..5).days.ago)
      end
      # --- end of canceled_by_student

      # --- expired
      student = college_rep_active_students[5]
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.expire!(Users::God.first)
        app.update_columns(expired_at: rand(10..20).days.ago, submitted_at: rand(25..35).days.ago)
      end
      # --- end of expired

      # --- expired_by_student
      student = college_rep_active_students[6]
      targeted_offer = paris_offers.troisieme_or_quatrieme.second
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.expire_by_student!(Users::God.first)
        app.update_columns(expired_at: rand(5..15).days.ago)
      end
      # --- end of expired_by_student

      # --- canceled_by_student_confirmation (élève annule après validation employeur)
      student = college_rep_active_students[7]
      targeted_offer = paris_offers.troisieme_or_quatrieme.third
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!(Users::God.first)
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_student_confirmation!(Users::God.first)
      end
      # --- end of canceled_by_student_confirmation

      # --- restored (candidature annulée puis restaurée)
      student = college_rep_active_students[8]
      targeted_offer = paris_offers.troisieme_or_quatrieme.first
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_offer.weeks.first ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_student!(Users::God.first)
        app.skip_callback_with_review_rebuild = true
        app.restore!(Users::God.first)
        app.update_columns(restored_at: rand(1..3).days.ago, canceled_at: rand(5..10).days.ago)
      end
      # --- end of restored
    end

    # Logic for creating applications for 2de
    def create_applications_for_secondes
      student = lycee_qpv_students.first
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 0,
        week_index: 0,
        context: "secondes just submitted qpv"
      )
      # just submitted
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_week ]
      )
      # -----------
      student = lycee_standard_students.first
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 1,
        week_index: 1,
        week_fallback_index: 0,
        context: "secondes just submitted standard"
      )
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_week ]
      )
      # --- end of submitted

      student = lycee_qpv_students.second
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 1,
        week_index: 0,
        context: "secondes approved qpv"
      )
      # approved
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_week ]
      )
      lycee_qpv_students[5..12].each do |stu|
        application_maker(
          student: stu,
          targeted_offer: targeted_offer,
          weeks: [ targeted_week ]
        )
      end
      approve_applications(InternshipApplication.order(created_at: :desc).first(4))
      # -----------
      student = lycee_standard_students.second
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: -1,
        week_index: 1,
        week_fallback_index: 0,
        context: "secondes approved standard"
      )
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_week ]
      )

      # end of approved ----
      # --- rejected
      student = lycee_qpv_students.third
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde.published,
        offer_index: 2,
        offer_fallback_indexes: [ 1, 0 ],
        week_index: 1,
        week_fallback_index: 0,
        context: "secondes rejected qpv"
      )
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_week ]
      )
      student = lycee_standard_students.third
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde.published,
        offer_index: 2,
        offer_fallback_indexes: [ 1, 0 ],
        week_index: 1,
        week_fallback_index: 0,
        context: "secondes rejected standard"
      )
      application_maker(
        student: student,
        targeted_offer: targeted_offer,
        weeks: [ targeted_week ]
      )
      InternshipApplication.last(2).each { |app| app.reject! }
      # --- end of rejected

      # --- read_by_employer
      student = lycee_rep_active_students.first
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 0,
        week_index: 0,
        context: "secondes read_by_employer rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.read!(Users::God.first)
      end
      # --- end of read_by_employer

      # --- transfered
      student = lycee_rep_active_students.second
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 1,
        week_index: 0,
        context: "secondes transfered rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.transfer!(Users::God.first)
        app.update_columns(transfered_at: rand(3..7).days.ago)
      end
      # --- end of transfered

      # --- validated_by_employer
      student = lycee_rep_active_students.third
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 1,
        week_index: 0,
        week_fallback_index: 0,
        context: "secondes validated_by_employer rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!(Users::God.first)
        app.update_columns(validated_by_employer_at: rand(2..4).days.ago)
      end
      # --- end of validated_by_employer

      # --- canceled_by_employer
      student = lycee_rep_active_students[3]
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 0,
        week_index: 0,
        context: "secondes canceled_by_employer rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!(Users::God.first)
        app.approve!(Users::God.first)
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_employer!(Users::God.first)
        app.update_columns(canceled_at: rand(1..3).days.ago)
      end
      # --- end of canceled_by_employer

      # --- canceled_by_student
      student = lycee_rep_active_students[4]
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: -1,
        week_index: 0,
        context: "secondes canceled_by_student rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_student!(Users::God.first)
        app.update_columns(canceled_at: rand(1..5).days.ago)
      end
      # --- end of canceled_by_student

      # --- expired
      student = lycee_rep_active_students[5]
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 0,
        week_index: 0,
        context: "secondes expired rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.expire!(Users::God.first)
        app.update_columns(expired_at: rand(10..20).days.ago, submitted_at: rand(25..35).days.ago)
      end
      # --- end of expired

      # --- expired_by_student
      student = lycee_rep_active_students[6]
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 1,
        week_index: 0,
        context: "secondes expired_by_student rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.expire_by_student!(Users::God.first)
        app.update_columns(expired_at: rand(5..15).days.ago)
      end
      # --- end of expired_by_student

      # --- canceled_by_student_confirmation
      student = lycee_rep_active_students[7]
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: -1,
        week_index: 0,
        context: "secondes canceled_by_student_confirmation rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.employer_validate!(Users::God.first)
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_student_confirmation!(Users::God.first)
      end
      # --- end of canceled_by_student_confirmation

      # --- restored
      student = lycee_rep_active_students[8]
      targeted_offer, targeted_week = fetch_offer_and_week!(
        offers: paris_offers.seconde,
        offer_index: 0,
        week_index: 0,
        context: "secondes restored rep"
      )
      app = application_maker(student: student, targeted_offer: targeted_offer, weeks: [ targeted_week ])
      if app
        app.skip_callback_with_review_rebuild = true
        app.cancel_by_student!(Users::God.first)
        app.skip_callback_with_review_rebuild = true
        app.restore!(Users::God.first)
        app.update_columns(restored_at: rand(1..3).days.ago, canceled_at: rand(5..10).days.ago)
      end
      # --- end of restored
    end

    # -- helpers

    def first_week_seconde
      SchoolTrack::Seconde.first_week
    end

    def second_week_seconde
      SchoolTrack::Seconde.second_week
    end

    def both_weeks_seconde
      [ first_week_seconde, second_week_seconde ]
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

    def college_rep_active_students = Users::Student.where(school: college_rep, anonymized: false).order(id: :desc).to_a
    def lycee_rep_active_students   = Users::Student.where(school: lycee_rep,   anonymized: false).order(id: :desc).to_a

    def paris_offers
      InternshipOffers::WeeklyFramed.where(city: "Paris")
    end

    def fetch_offer_and_week!(offers:, offer_index:, week_index:, context:, week_fallback_index: nil,
                              offer_fallback_indexes: [])
      offers_arr = offers.to_a
      targeted_offer = offers_arr[offer_index]
      if targeted_offer.nil?
        offer_fallback_indexes.each do |fallback_offer_index|
          targeted_offer = offers_arr[fallback_offer_index]
          break unless targeted_offer.nil?
        end
      end
      raise StandardError, "#{context}: missing offer at index #{offer_index}" if targeted_offer.nil?

      weeks_arr = targeted_offer.weeks.to_a
      targeted_week = weeks_arr[week_index]
      targeted_week ||= weeks_arr[week_fallback_index] unless week_fallback_index.nil?
      raise StandardError, "#{context}: offer ##{targeted_offer.id} has no week at index #{week_index}" if targeted_week.nil?

      [ targeted_offer, targeted_week ]
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
