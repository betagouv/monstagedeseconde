require 'test_helper'

class DoublingOffersTest < ActiveSupport::TestCase

  test 'retrofit:doubling_offers with multiple grades and applications of both grades' do
    travel_to Date.new(2023, 10, 1) do
      #setup
      internship_offer = create(:weekly_internship_offer,
                                :both_school_tracks_internship_offer,
                                max_candidates: 3,
                                grades: [Grade.seconde] + Grade.troisieme_et_quatrieme,
                                weeks: [Week.seconde_weeks.first] + Week.where(year: 2024, number: [1,2]).to_a
                                )
      original_created_at = internship_offer.created_at
      original_updated_at = internship_offer.updated_at
      lycee_school         = create(:school, :lycee, :at_paris)
      college_school       = create(:school, :college, :at_bordeaux)
      internship_offer.schools = [lycee_school, college_school]
      student_seconde       = create(:student, :female, grade: Grade.seconde)
      student_troisieme     = create(:student, :male, grade: Grade.troisieme)
      application_seconde   = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde)
      application_troisieme = create(:weekly_internship_application, internship_offer: internship_offer, student: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_seconde)
      internship_offer.reload.update_stats

      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_equal 2, internship_offer.schools.count
      assert_equal "2024/01/01", internship_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/06/21", internship_offer.last_date.strftime("%Y/%m/%d")


      internship_offer.split_offer


      internship_offer.reload
      assert_equal "2024/06/17", internship_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/06/21", internship_offer.last_date.strftime("%Y/%m/%d")
      assert_equal [Grade.seconde.id], internship_offer.grades.ids
      assert_equal [application_seconde.id], internship_offer.internship_applications.to_a.map(&:id)
      assert_equal [Week.seconde_weeks.first.id], internship_offer.weeks.ids
      assert_equal 1, internship_offer.favorites.count
      assert_equal student_seconde.id, internship_offer.favorites.first.user.id
      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 1, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 1, internship_offer.stats.submitted_applications_count
      assert_equal 0, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_equal 1, internship_offer.schools.count
      assert_equal internship_offer.schools.first.id, lycee_school.id

      assert_equal original_created_at, internship_offer.created_at
      assert_equal original_updated_at, internship_offer.updated_at

      new_offer = InternshipOffer.find_by(mother_id: internship_offer.id)
      assert_not_nil new_offer
      assert_equal "2024/01/01", new_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/01/12", new_offer.last_date.strftime("%Y/%m/%d")
      assert_equal Grade.troisieme_et_quatrieme.ids, new_offer.grades.map(&:id)
      assert_equal [application_troisieme.id], new_offer.internship_applications.to_a.map(&:id)
      assert_equal Week.where(year: 2024, number: [1,2]).to_a.map(&:id), new_offer.weeks.ids
      assert_equal 1, new_offer.favorites.count
      assert_equal student_troisieme.id, new_offer.favorites.first.user.id
      assert_equal 3, new_offer.stats.remaining_seats_count
      assert_equal 1, new_offer.stats.total_applications_count
      assert_equal 0, new_offer.stats.approved_applications_count
      assert_equal 1, new_offer.stats.submitted_applications_count
      assert_equal 1, new_offer.stats.total_male_applications_count
      assert_equal 0, new_offer.stats.total_female_applications_count
      assert_equal 0, new_offer.stats.total_male_approved_applications_count
      assert_equal 0, new_offer.stats.total_female_approved_applications_count

      assert_equal 1, new_offer.schools.count
      assert_equal new_offer.schools.first.id, college_school.id

      assert_equal original_created_at, new_offer.created_at
      assert_equal original_updated_at, new_offer.updated_at
    end
  end

  test 'retrofit:doubling_offers with multiple grades and applications of both grades when offer is multi' do
    travel_to Date.new(2023, 10, 1) do
      #setup
      internship_offer = create(:multi_internship_offer,
                                :both_school_tracks_internship_offer,
                                max_candidates: 3,
                                grades: [Grade.seconde] + Grade.troisieme_et_quatrieme,
                                weeks: [Week.seconde_weeks.first] + Week.where(year: 2024, number: [1,2]).to_a
                                )
      original_created_at = internship_offer.created_at
      original_updated_at = internship_offer.updated_at
      lycee_school         = create(:school, :lycee, :at_paris)
      college_school       = create(:school, :college, :at_bordeaux)
      internship_offer.schools = [lycee_school, college_school]
      student_seconde       = create(:student, :female, grade: Grade.seconde)
      student_troisieme     = create(:student, :male, grade: Grade.troisieme)
      application_seconde   = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde)
      application_troisieme = create(:weekly_internship_application, internship_offer: internship_offer, student: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_seconde)
      internship_offer.reload.update_stats

      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_equal 2, internship_offer.schools.count
      assert_equal "2024/01/01", internship_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/06/21", internship_offer.last_date.strftime("%Y/%m/%d")


      internship_offer.split_offer
      internship_offer.reload

      assert_equal "2024/06/17", internship_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/06/21", internship_offer.last_date.strftime("%Y/%m/%d")
      assert_equal [Grade.seconde.id], internship_offer.grades.ids
      assert_equal [application_seconde.id], internship_offer.internship_applications.to_a.map(&:id)
      assert_equal [Week.seconde_weeks.first.id], internship_offer.weeks.ids
      assert_equal 1, internship_offer.favorites.count
      assert_equal student_seconde.id, internship_offer.favorites.first.user.id
      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 1, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 1, internship_offer.stats.submitted_applications_count
      assert_equal 0, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_equal 1, internship_offer.schools.count
      assert_equal internship_offer.schools.first.id, lycee_school.id

      assert_equal original_created_at, internship_offer.created_at
      assert_equal original_updated_at, internship_offer.updated_at

      new_offer = InternshipOffer.find_by(mother_id: internship_offer.id)
      assert_not_nil new_offer
      assert_equal "2024/01/01", new_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/01/12", new_offer.last_date.strftime("%Y/%m/%d")
      assert_equal Grade.troisieme_et_quatrieme.ids, new_offer.grades.map(&:id)
      assert_equal [application_troisieme.id], new_offer.internship_applications.to_a.map(&:id)
      assert_equal Week.where(year: 2024, number: [1,2]).to_a.map(&:id), new_offer.weeks.ids
      assert_equal 1, new_offer.favorites.count
      assert_equal student_troisieme.id, new_offer.favorites.first.user.id
      assert_equal 3, new_offer.stats.remaining_seats_count
      assert_equal 1, new_offer.stats.total_applications_count
      assert_equal 0, new_offer.stats.approved_applications_count
      assert_equal 1, new_offer.stats.submitted_applications_count
      assert_equal 1, new_offer.stats.total_male_applications_count
      assert_equal 0, new_offer.stats.total_female_applications_count
      assert_equal 0, new_offer.stats.total_male_approved_applications_count
      assert_equal 0, new_offer.stats.total_female_approved_applications_count

      assert_equal 1, new_offer.schools.count
      assert_equal new_offer.schools.first.id, college_school.id

      assert_equal original_created_at, new_offer.created_at
      assert_equal original_updated_at, new_offer.updated_at
    end
  end

  test 'retrofit:doubling_offers with older than a year offer with multiple grades and applications of both grades' do
    travel_to Date.new(2024, 10, 1) do
      #setup
      weeks1 = [Week.find_by(number: 25, year: 2024)]
      weeks2 =  Week.where(year: 2024, number: [1,2]).to_a
      weeks = weeks1 + weeks2
      internship_offer = create(:weekly_internship_offer,
                                :both_school_tracks_internship_offer,
                                max_candidates: 3,
                                grades: [Grade.seconde] + Grade.troisieme_et_quatrieme,
                                weeks: weeks )
      original_created_at = internship_offer.created_at
      original_updated_at = internship_offer.updated_at
      lycee_school         = create(:school, :lycee, :at_paris)
      college_school       = create(:school, :college, :at_bordeaux)
      internship_offer.schools = [lycee_school, college_school]
      student_seconde       = create(:student, :female, grade: Grade.seconde)
      student_troisieme     = create(:student, :male, grade: Grade.troisieme)
      application_seconde   = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde)
      application_troisieme = create(:weekly_internship_application, internship_offer: internship_offer, student: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_seconde)
      internship_offer.reload.update_stats

      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_equal 2, internship_offer.schools.count
      assert_equal "2024/01/01", internship_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/06/21", internship_offer.last_date.strftime("%Y/%m/%d")


      internship_offer.split_offer


      internship_offer.reload
      assert_equal "2024/06/17", internship_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/06/21", internship_offer.last_date.strftime("%Y/%m/%d")
      assert_equal [Grade.seconde.id], internship_offer.grades.ids
      assert_equal [application_seconde.id], internship_offer.internship_applications.to_a.map(&:id)
      assert_equal [weeks.first.id], internship_offer.weeks.ids
      assert_equal 0, internship_offer.favorites.count
      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 1, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 1, internship_offer.stats.submitted_applications_count
      assert_equal 0, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_equal 1, internship_offer.schools.count
      assert_equal internship_offer.schools.first.id, lycee_school.id

      assert_equal original_created_at, internship_offer.created_at
      assert_equal original_updated_at, internship_offer.updated_at

      new_offer = InternshipOffer.find_by(mother_id: internship_offer.id)
      assert_not_nil new_offer
      assert_equal "2024/01/01", new_offer.first_date.strftime("%Y/%m/%d")
      assert_equal "2024/01/12", new_offer.last_date.strftime("%Y/%m/%d")
      assert_equal Grade.troisieme_et_quatrieme.ids, new_offer.grades.map(&:id)
      assert_equal [application_troisieme.id], new_offer.internship_applications.to_a.map(&:id)
      assert_equal weeks2.map(&:id).sort, new_offer.weeks.ids.sort
      assert_equal 0, new_offer.favorites.count
      assert_equal 3, new_offer.stats.remaining_seats_count
      assert_equal 1, new_offer.stats.total_applications_count
      assert_equal 0, new_offer.stats.approved_applications_count
      assert_equal 1, new_offer.stats.submitted_applications_count
      assert_equal 1, new_offer.stats.total_male_applications_count
      assert_equal 0, new_offer.stats.total_female_applications_count
      assert_equal 0, new_offer.stats.total_male_approved_applications_count
      assert_equal 0, new_offer.stats.total_female_approved_applications_count

      assert_equal 1, new_offer.schools.count
      assert_equal new_offer.schools.first.id, college_school.id

      assert_equal original_created_at, new_offer.created_at
      assert_equal original_updated_at, new_offer.updated_at
    end
  end

  test 'retrofit:doubling_API offers with multiple grades' do
    travel_to Date.new(2024, 10, 1) do
      #setup
      internship_offer = create(:api_internship_offer,
                                :both_school_tracks_internship_offer,
                                max_candidates: 3,
                                grades: [Grade.seconde] + Grade.troisieme_et_quatrieme,
                                weeks: [Week.seconde_weeks.first] + Week.where(year: 2025, number: [1,2]).to_a
                                )
      lycee_school         = create(:school, :lycee, :at_paris)
      college_school       = create(:school, :college, :at_bordeaux)
      internship_offer.schools = [lycee_school, college_school]
      student_seconde       = create(:student, :female, grade: Grade.seconde)
      student_troisieme     = create(:student, :male, grade: Grade.troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_troisieme)
      create(:favorite, internship_offer: internship_offer, user: student_seconde)

      assert_equal 2, internship_offer.schools.count

      assert_no_changes -> { UsersInternshipOffersHistory.count } do
        internship_offer.split_offer
      end

      internship_offer.reload

      assert_equal [Grade.seconde.id], internship_offer.grades.ids
      assert_equal [Week.seconde_weeks.first.id], internship_offer.weeks.ids
      assert_equal 1, internship_offer.favorites.count
      assert_equal student_seconde.id, internship_offer.favorites.first.user.id

      assert_equal 1, internship_offer.schools.count
      assert_equal internship_offer.schools.first.id, lycee_school.id
    end
  end

  test 'retrofit:doubling_offers with grade 3e and applications' do
    travel_to Date.new(2024, 10, 1) do
      #setup
      internship_offer = create(:weekly_internship_offer,
                                :week_1,
                                max_candidates: 3,
                                grades: [Grade.seconde],
                                weeks: [Week.seconde_weeks.first]
                                )
      student_seconde_f = create(:student, :female, grade: Grade.seconde)
      student_seconde_m = create(:student, :male, grade: Grade.seconde)
      application_seconde_f = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde_f)
      application_seconde_m = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde_m)
      create(:favorite, internship_offer: internship_offer, user: student_seconde_f)
      create(:favorite, internship_offer: internship_offer, user: student_seconde_m)
      internship_offer.reload.update_stats

      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_no_changes -> { UsersInternshipOffersHistory.count } do
        internship_offer.split_offer
      end

      internship_offer.reload
      assert_equal [Grade.seconde.id], internship_offer.grades.ids
      assert_equal [application_seconde_f.id, application_seconde_m.id].sort, internship_offer.internship_applications.to_a.map(&:id).sort
      assert_equal [Week.seconde_weeks.first.id], internship_offer.weeks.ids
      assert_equal 2, internship_offer.favorites.count
      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

    end
  end

  test 'retrofit:doubling_offers fails gracefully when weeks are missing in 3eme grade' do
    travel_to Date.new(2024, 10, 1) do
      #setup
      internship_offer = create(:weekly_internship_offer,
                                :week_1,
                                max_candidates: 3,
                                grades: [Grade.troisieme, Grade.seconde],
                                weeks: [Week.seconde_weeks.first]
                                )
      student_seconde_f = create(:student, :female, grade: Grade.seconde)
      student_seconde_m = create(:student, :male, grade: Grade.seconde)
      application_seconde_f = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde_f)
      application_seconde_m = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde_m)
      create(:favorite, internship_offer: internship_offer, user: student_seconde_f)
      create(:favorite, internship_offer: internship_offer, user: student_seconde_m)
      internship_offer.reload.update_stats

      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_no_changes -> { UsersInternshipOffersHistory.count } do
        internship_offer.split_offer
      end
    end
  end

  test 'retrofit:doubling_offers fails gracefully when weeks are missing in 2nde grade' do
    travel_to Date.new(2024, 10, 1) do
      #setup
      internship_offer = create(:weekly_internship_offer,
                                :week_1,
                                max_candidates: 3,
                                grades: [Grade.quatrieme, Grade.troisieme, Grade.seconde],
                                weeks: Week.where(year: 2025, number: [1,2])
                                )
      student_seconde_f = create(:student, :female, grade: Grade.seconde)
      student_seconde_m = create(:student, :male, grade: Grade.seconde)
      application_seconde_f = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde_f)
      application_seconde_m = create(:weekly_internship_application, internship_offer: internship_offer, student: student_seconde_m)
      create(:favorite, internship_offer: internship_offer, user: student_seconde_f)
      create(:favorite, internship_offer: internship_offer, user: student_seconde_m)
      internship_offer.reload.update_stats

      assert_equal 3, internship_offer.stats.remaining_seats_count
      assert_equal 2, internship_offer.stats.total_applications_count
      assert_equal 0, internship_offer.stats.approved_applications_count
      assert_equal 2, internship_offer.stats.submitted_applications_count
      assert_equal 1, internship_offer.stats.total_male_applications_count
      assert_equal 1, internship_offer.stats.total_female_applications_count
      assert_equal 0, internship_offer.stats.total_male_approved_applications_count
      assert_equal 0, internship_offer.stats.total_female_approved_applications_count

      assert_no_changes -> { UsersInternshipOffersHistory.count } do
        assert_no_changes -> { InternshipOffer.count } do
          internship_offer.split_offer
        end
      end
      internship_offer.reload
      assert_equal [Grade.troisieme.id, Grade.quatrieme.id].sort, internship_offer.grades.ids.sort
      assert_equal [application_seconde_f.id, application_seconde_m.id].sort, internship_offer.internship_applications.to_a.map(&:id).sort
    end
  end
end