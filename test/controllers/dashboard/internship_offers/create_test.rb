# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'POST #create (duplicate)  as visitor redirects to internship_offers' do
      post dashboard_internship_offers_path(params: {})
      assert_redirected_to user_session_path
    end

    test 'POST #create (duplicate) /InternshipOffers::WeeklyFramed as employer creates the post' do
      travel_to(Date.new(2024, 3, 1)) do
        schools = [create(:school), create(:school)]
        employer = create(:employer)
        internship_offer = build(:weekly_internship_offer_3eme, employer:)
        sign_in(internship_offer.employer)
        params = internship_offer
                 .attributes
                 .merge('type' => InternshipOffers::WeeklyFramed.name,
                        'coordinates' => { latitude: 1, longitude: 1 },
                        'school_ids' => schools.map(&:id),
                        'description' => '<div>description</div>',
                        'employer_description' => 'hop+employer_description',
                        'week_ids' => internship_offer.weeks.ids,
                        'grade_ids' => internship_offer.grades.ids,
                        'max_candidates' => 1,
                        'employer_id' => internship_offer.employer_id,
                        'employer_type' => 'Users::Employer')
                 .deep_symbolize_keys
        assert_difference('InternshipOffer.count', 1) do
          post(dashboard_internship_offers_path,
               params: { internship_offer: params })
        end
        created_internship_offer = InternshipOffer.last
        assert_equal InternshipOffers::WeeklyFramed.name, created_internship_offer.type
        assert_equal employer, created_internship_offer.employer
        assert_equal params[:max_candidates], created_internship_offer.max_candidates
        assert_equal params[:max_candidates], created_internship_offer.remaining_seats_count
        assert_equal params[:school_ids].sort, created_internship_offer.schools.map(&:id).sort
        assert_equal params[:week_ids], created_internship_offer.weeks.map(&:id)
        assert_equal params[:grade_ids], created_internship_offer.grades.map(&:id)
        assert_redirected_to internship_offer_path(created_internship_offer, stepper: true)
      end
    end

    test 'POST #create  - duplicate - InternshipOffers::WeeklyFramed as employer creates the post' do
      travel_to(Date.new(2025, 3, 1)) do
        school = create(:school)
        employer = create(:employer)
        original_internship_offer = create(:weekly_internship_offer_3eme, employer:)

        sign_in(original_internship_offer.employer)
        params = original_internship_offer
                 .attributes
                 .merge('type' => InternshipOffers::WeeklyFramed.name,
                        'coordinates' => { latitude: 1, longitude: 1 },
                        'school_id' => school.id,
                        'description' => '<div>description</div>',
                        'employer_description' => 'hop+employer_description',
                        'week_ids' => original_internship_offer.weeks.ids,
                        'grade_ids' => original_internship_offer.grades.ids,
                        'max_candidates' => 1,
                        'employer_id' => original_internship_offer.employer_id,
                        'duplicate_id' => original_internship_offer.id,
                        'employer_type' => 'Users::Employer')
                 .deep_symbolize_keys
        assert_difference('InternshipOffer.count', 1) do
          post(dashboard_internship_offers_path,
               params: { internship_offer: params })
        end
        created_internship_offer = InternshipOffer.last
        assert_equal original_internship_offer.title, created_internship_offer.title
        assert_equal original_internship_offer.employer, created_internship_offer.employer
        assert_equal original_internship_offer.max_candidates, created_internship_offer.max_candidates
        assert_equal original_internship_offer.remaining_seats_count, created_internship_offer.remaining_seats_count
        assert_redirected_to internship_offer_path(created_internship_offer, stepper: true)
      end
    end
    test 'POST #create  - duplicate  and change internship_offer_area_id - InternshipOffers::WeeklyFramed as employer creates the post' do
      travel_to(Date.new(2025, 3, 1)) do
        school = create(:school)
        employer = create(:employer)
        original_internship_offer = create(:weekly_internship_offer_3eme, employer:)
        internship_offer_area = create(:internship_offer_area, employer:)

        sign_in(original_internship_offer.employer)
        params = original_internship_offer
                 .attributes
                 .merge('type' => InternshipOffers::WeeklyFramed.name,
                        'coordinates' => { latitude: 1, longitude: 1 },
                        'school_id' => school.id,
                        'description' => '<div>description</div>',
                        'employer_description' => 'hop+employer_description',
                        'week_ids' => original_internship_offer.weeks.ids,
                        'grade_ids' => original_internship_offer.grades.ids,
                        'max_candidates' => 1,
                        'employer_id' => original_internship_offer.employer_id,
                        'duplicate_id' => original_internship_offer.id,
                        'internship_offer_area_id' => internship_offer_area.id,
                        'employer_type' => 'Users::Employer')
                 .deep_symbolize_keys
        assert_difference('InternshipOffer.count', 1) do
          post(dashboard_internship_offers_path,
               params: { internship_offer: params })
        end
        created_internship_offer = InternshipOffer.last
        assert_equal original_internship_offer.title, created_internship_offer.title
        assert_equal original_internship_offer.employer, created_internship_offer.employer
        assert_equal original_internship_offer.max_candidates, created_internship_offer.max_candidates
        assert_equal original_internship_offer.remaining_seats_count, created_internship_offer.remaining_seats_count
        assert_equal internship_offer_area, created_internship_offer.internship_offer_area
        assert_redirected_to internship_offer_path(created_internship_offer, stepper: true)
      end
    end

    test 'POST #create (duplicate) /InternshipOffers::WeeklyFramed as ministry statistican creates the post' do
      travel_to(Date.new(2024, 9, 1)) do
        school = create(:school)
        employer = create(:ministry_statistician)
        internship_offer = build(:weekly_internship_offer_3eme, :public, employer:)
        sign_in(internship_offer.employer)
        params = internship_offer
                 .attributes
                 .merge('type' => InternshipOffers::WeeklyFramed.name,
                        'group' => employer.ministries.first,
                        'coordinates' => { latitude: 1, longitude: 1 },
                        'week_ids' => internship_offer.weeks.map(&:id),
                        'grade_ids' => internship_offer.grades.map(&:id),
                        'school_id' => school.id,
                        'description' => '<div>description</div>',
                        'employer_type' => 'Users::MinistryStatistician')

        assert_difference('InternshipOffer.count', 1) do
          post(dashboard_internship_offers_path, params: { internship_offer: params })
        end
        created_internship_offer = InternshipOffer.last
        assert_equal InternshipOffers::WeeklyFramed.name, created_internship_offer.type
        assert_equal employer, created_internship_offer.employer
        assert_equal params['max_candidates'], created_internship_offer.max_candidates
        assert_equal Group.all.last, created_internship_offer.group
        assert_redirected_to internship_offer_path(created_internship_offer, stepper: true)
      end
    end

    test 'POST #create as employer with invalid data, prefills form' do
      skip 'TODO: fix this test'
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: {
             internship_offer: {
               title: 'hello',
               is_public: false,
               max_candidates: 2
             }
           })
      assert_select('.fr-alert.fr-alert--error strong', html: /Code postal/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Description/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Secteur/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Coordonnées GPS/)

      assert_select('.fr-alert.fr-alert--error', html: /Veuillez renseigner le code postal de l'employeur/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez saisir une description pour l'offre de stage/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez saisir le nom de l'employeur/)
      assert_select('.fr-alert.fr-alert--error',
                    html: /Veuillez renseigner la rue ou compléments d'adresse de l'offre de stage/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez saisir le nom de commune de l'offre de stage/)

      assert_select '.form-group-select-group.d-none', count: 0

      assert_select '.form-group-select-max-candidates.d-none', count: 0
    end
  end
end
