# frozen_string_literal: true

require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'weekly_internship_offer_2nde factory is valid' do
    weekly_internship_offer = build(:weekly_internship_offer_2nde)
    validity = weekly_internship_offer.valid?
    puts weekly_internship_offer.errors.full_messages unless validity
    assert build(:weekly_internship_offer_2nde).valid?
  end

  test 'api factory is valid' do
    assert build(:api_internship_offer_2nde).valid?
  end

  test 'multi_internship_offer factory is valid' do
    assert build(:multi_internship_offer).valid?
  end

  test 'create enqueue SyncInternshipOfferKeywordsJob' do
    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      create(:weekly_internship_offer_2nde)
    end
  end

  test 'destroy enqueue SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer_2nde)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.destroy
    end
  end

  test 'update title enqueues SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer_2nde)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(title: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(description: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(employer_description: 'bingo bango bang')
    end

    assert_enqueued_jobs 0, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(first_date: 2.days.from_now)
    end
  end

  test 'faulty zipcode' do
    internship_offer = create(:weekly_internship_offer_2nde)
    internship_offer.update_columns(zipcode: 'xy752')

    refute internship_offer.valid?
    assert_equal ['Code postal le code postal ne permet pas de déduire le département'],
                 internship_offer.errors.full_messages
  end

  test 'is_favorite?' do
    student = create(:student)
    other_student = create(:student)
    internship_offer = create(:weekly_internship_offer_2nde)
    other_internship_offer = create(:weekly_internship_offer_2nde)
    refute internship_offer.is_favorite?(student)

    create(:favorite, user: student, internship_offer:)
    create(:favorite, user: other_student, internship_offer: other_internship_offer)
    refute internship_offer.is_favorite?(other_student)
    assert internship_offer.is_favorite?(student)
  end

  test 'when bulking internship_offer is created, make sure area is set' do
    employer = create(:employer)
    assert_equal 1, employer.internship_offer_areas.count
    offer = build(:weekly_internship_offer_2nde, employer:)
    offer.internship_offer_area_id = nil
    assert offer.valid?
    assert offer.save
    assert offer.internship_offer_area_id.present?
    assert_equal employer.current_area_id, offer.internship_offer_area_id
  end

  test 'school_year value' do
    travel_to(Date.new(2025, 3, 1)) do
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      assert_equal 2025, internship_offer.school_year
    end
  end

  test 'targeted_grades enum' do
    travel_to Date.new(2023, 10, 1) do
      internship_offer = create(:weekly_internship_offer_2nde, :week_1)
      assert_equal 'seconde_only', internship_offer.targeted_grades
      internship_offer.grades << Grade.troisieme_et_quatrieme
      internship_offer.save
      assert_equal 'seconde_troisieme_or_quatrieme', internship_offer.targeted_grades

      internship_offer = create(:weekly_internship_offer_3eme)
      internship_offer.save
      assert_equal 'troisieme_or_quatrieme', internship_offer.targeted_grades
      internship_offer.grades << [Grade.seconde, Grade.quatrieme]
      internship_offer.save
      assert_equal 'seconde_troisieme_or_quatrieme', internship_offer.targeted_grades

      internship_offer = create(:weekly_internship_offer_3eme)
      internship_offer.save
      assert_equal 'troisieme_or_quatrieme', internship_offer.targeted_grades
      internship_offer.grades << [Grade.seconde]
      internship_offer.save
      assert_equal 'seconde_troisieme_or_quatrieme', internship_offer.targeted_grades
    end
  end

  test '.two_weeks_long?' do
    # 2 weeks test
    internship_offer = create(:weekly_internship_offer_2nde, :both_weeks)
    assert internship_offer.two_weeks_long?

    # First week test
    internship_offer = create(:weekly_internship_offer_2nde, :week_1)
    refute internship_offer.two_weeks_long?

    # Second week test
    internship_offer = create(:weekly_internship_offer_2nde, :week_2)
    refute internship_offer.two_weeks_long?
  end

  test "factory 'multi'" do
    internship_offer = build(:multi_internship_offer)
    assert internship_offer.valid?
    refute_nil internship_offer.multi_corporation
    internship_offer.save!
    assert_equal 5, internship_offer.corporations.count
  end

  # test '.period_labels' do
  #   assert_equal '2 semaines (du 17 au 28 juin 2024)',
  #                InternshipOffer.period_labels(school_year: 2024)[:full_time]
  #   assert_equal '1 semaine (du 16 au 20 juin 2025)',
  #                InternshipOffer.period_labels(school_year: 2025)[:week_1]
  #   assert_equal '1 semaine (du 23 au 27 juin 2025)',
  #                InternshipOffer.period_labels(school_year: 2025)[:week_2]
  # end

  # test '.current_period_labels' do
  #   travel_to(Date.new(2024, 7, 17)) do
  #     assert_equal '2 semaines (du 16 au 27 juin 2025)',
  #                  InternshipOffer.current_period_labels[:full_time]
  #     assert_equal '1 semaine (du 16 au 20 juin 2025)',
  #                  InternshipOffer.current_period_labels[:week_1]
  #     assert_equal '1 semaine (du 23 au 27 juin 2025)',
  #                  InternshipOffer.current_period_labels[:week_2]
  #   end
  # # end

  # test '#current_period_label' do
  #   travel_to(Date.new(2024, 7, 17)) do
  #     internship_offer = create(:weekly_internship_offer_2nde, :week_1)
  #     assert_equal '1 semaine - du 16 au 20 juin 2025', internship_offer.current_period_label
  #   end
  # end

  test 'scope ignore_internship_restricted_to_other_schools' do
    school1 = create(:school) #school that will be reserved
    school2 = create(:school)
    school3 = create(:school)
    school4 = create(:school)
    employer1 = create(:employer)
    student1 = create(:student, school: school1)
    student2 = create(:student, school: school2)
    student3 = create(:student, school: school3)
    student4 = create(:student, school: school4)

    internship_offer1 = create(:weekly_internship_offer_2nde, employer: employer1)
    internship_offer1.schools << school1
    internship_offer1.schools << school3

    internship_offer2 = create(:weekly_internship_offer_2nde, employer: employer1)
    internship_offer2.schools << school2
    internship_offer2.schools << school3

    internship_offer3 = create(:weekly_internship_offer_2nde, employer: employer1)
    internship_offer4 = create(:weekly_internship_offer_2nde, employer: employer1)

    offers = InternshipOffer.ignore_internship_restricted_to_other_schools(school_id: student1.school.id)
    assert offers.include?(internship_offer1)
    refute offers.include?(internship_offer2)
    assert offers.include?(internship_offer3)
    assert offers.include?(internship_offer4)

    offers = InternshipOffer.ignore_internship_restricted_to_other_schools(school_id: student2.school.id)
    assert offers.include?(internship_offer2)
    refute offers.include?(internship_offer1)
    assert offers.include?(internship_offer3)
    assert offers.include?(internship_offer4)

    offers = InternshipOffer.ignore_internship_restricted_to_other_schools(school_id: student3.school.id)
    assert offers.include?(internship_offer1)
    assert offers.include?(internship_offer2)
    assert offers.include?(internship_offer3)
    assert offers.include?(internship_offer4)

    offers = InternshipOffer.ignore_internship_restricted_to_other_schools(school_id: student4.school.id)
    refute offers.include?(internship_offer1)
    refute offers.include?(internship_offer2)
    assert offers.include?(internship_offer3)
    assert offers.include?(internship_offer4)
  end

  test 'scope seconde_and_troisieme' do
    create(:weekly_internship_offer_2nde)
    assert_equal 0, InternshipOffer.seconde_and_troisieme.ids.count
    create(:weekly_internship_offer_2nde, grades: [Grade.seconde, Grade.troisieme, Grade.quatrieme])
    assert_equal 1, InternshipOffer.seconde_and_troisieme.ids.count
    create(:weekly_internship_offer_2nde, grades: [Grade.troisieme, Grade.quatrieme])
    assert_equal 1, InternshipOffer.seconde_and_troisieme.ids.count
  end

  # Tests de cohérence is_public / sector / group_id
  test 'public offer requires group_id' do
    internship_offer = build(:weekly_internship_offer_2nde, is_public: true, group: nil)
    refute internship_offer.valid?
    assert_includes internship_offer.errors[:group_id], 'Un ministère est requis pour une offre publique'
  end

  test 'public offer must have sector Fonction publique' do
    group = create(:group, is_public: true)
    other_sector = create(:sector, name: 'Autre secteur')
    internship_offer = build(:weekly_internship_offer_2nde, is_public: true, group: group, sector: other_sector)
    assert internship_offer.valid?, internship_offer.errors.full_messages.join(', ')
    assert_equal 'Fonction publique', internship_offer.sector.name
  end

  test 'public offer with group_id is valid' do
    group = create(:group, is_public: true)
    internship_offer = build(:weekly_internship_offer_2nde, is_public: true, group: group)
    assert internship_offer.valid?, internship_offer.errors.full_messages.join(', ')
  end

  test 'private offer must not have group_id' do
    group = create(:group, is_public: true)
    sector = create(:sector, name: 'Secteur privé test')
    internship_offer = build(:weekly_internship_offer_2nde, is_public: false, group: group, sector: sector)
    refute internship_offer.valid?
    assert_includes internship_offer.errors[:group_id], "Il n'y a pas de ministère à associer à une entreprise privée"
  end

  test 'private offer must not have sector Fonction publique' do
    fonction_publique_sector = Sector.find_or_create_by!(name: 'Fonction publique')
    internship_offer = build(:weekly_internship_offer_2nde, is_public: false, group: nil, sector: fonction_publique_sector)
    refute internship_offer.valid?
    assert_includes internship_offer.errors[:sector_id], "Le secteur 'Fonction publique' n'est pas autorisé pour une offre privée"
  end

  test 'private offer without group_id and with valid sector is valid' do
    sector = create(:sector, name: 'Secteur privé valide')
    internship_offer = build(:weekly_internship_offer_2nde, is_public: false, group: nil, sector: sector)
    assert internship_offer.valid?, internship_offer.errors.full_messages.join(', ')
  end
end
