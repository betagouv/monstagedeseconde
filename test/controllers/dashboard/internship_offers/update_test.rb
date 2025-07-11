# frozen_string_literal: true

require 'test_helper'
module Dashboard::InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    # setup do
    #   InternshipOffer.all.each(&:destroy)
    # end

    def next_weeks_ids
      current_week = Week.current
      res = (current_week.id..(current_week.id + 3)).to_a
    end

    test 'PATCH #update as visitor redirects to user_session_path' do
      travel_to(Date.new(2024, 9, 1)) do
        internship_offer = create(:weekly_internship_offer_2nde)
        patch(dashboard_internship_offer_path(internship_offer.to_param), params: {})
        assert_redirected_to user_session_path
      end
    end

    test 'PATCH #update as employer not owning internship_offer redirects to user_session_path' do
      internship_offer = create(:weekly_internship_offer_2nde)
      sign_in(create(:employer))
      patch(
        dashboard_internship_offer_path(internship_offer.to_param),
        params: { internship_offer: { title: 'tsee' } }
      )
      assert_redirected_to root_path
    end

    test 'PATCH #update with title as employer owning internship_offer updates internship_offer' \
         'even if dates are missing in the future since it is not published' do
      # ability tests update for internship_offers with the existence of weeks
      # travel_to Date.new(2018, 9, 21) do
      #   internship_offer = create(:weekly_internship_offer_2nde, :unpublished, :with_public_group)
      #   new_title = 'new title'
      #   create(:sector, name: 'Fonction publique')
      #   sign_in(internship_offer.employer)
      #   patch(dashboard_internship_offer_path(internship_offer.to_param),
      #         params: { internship_offer: {
      #           title: new_title,
      #           week_ids: [weeks(:week_2019_1).id],
      #           is_public: true,
      #           published_at: nil,
      #           daily_hours: { 'lundi' => %w[10h 12h] }
      #         } })

      #   assert_redirected_to(dashboard_internship_offers_path(origine: 'dashboard'))

      #   assert_equal(new_title,
      #                internship_offer.reload.title,
      #                'can\'t update internship_offer title')
      #   assert_equal %w[10h 12h], internship_offer.reload.daily_hours['lundi']
      # end
    end

    test 'PATCH #update successfully with title as employer owning internship_offer updates internship_offer' do
      skip 'test is brittle but works when run alone' unless ENV.fetch('RUN_BRITTLE_TEST', false) == 'true'
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_2nde, :with_public_group)
        new_title = 'new title'
        new_group = create(:group, is_public: false, name: 'woop')
        sign_in(internship_offer.employer)
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: {
                internship_offer: {
                  title: new_title,
                  week_ids: Week.troisieme_selectable_weeks.map(&:id),
                  grade_college: '1',
                  grade_2e: '0',
                  all_year_long: '1',
                  group_id: new_group.id,
                  daily_hours: { 'lundi' => %w[10h 12h] },
                  workspace_conditions: 'Environnement de travail 2',
                  workspace_accessibility: 'Accessibilité du poste 2'
                }
              })

        assert_redirected_to(dashboard_internship_offers_path(origine: 'dashboard'))

        assert_equal(new_title,
                     internship_offer.reload.title,
                     'can\'t update internship_offer title')
        assert_equal %w[10h 12h], internship_offer.reload.daily_hours['lundi']
        assert_equal 'Environnement de travail 2', internship_offer.reload.workspace_conditions
        assert_equal 'Accessibilité du poste 2', internship_offer.reload.workspace_accessibility
      end
    end

    test 'PATCH #update as employer owning internship_offer ' \
         'updates internship_offer' do
      travel_to(Date.new(2024, 9, 1)) do
        internship_offer = create(:weekly_internship_offer_3eme, :public, max_candidates: 3)
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        sign_in(internship_offer.employer)
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: {
                max_candidates: 2
              } })
        follow_redirect!
        assert_select('#alert-text', text: 'Votre annonce a bien été modifiée')
        assert_equal 2, internship_offer.reload.max_candidates
      end
    end

    test 'PATCH #update as employer owning internship_offer ' \
         'updates internship_offer and fails due to too many accepted internships' do
      travel_to(Date.new(2024, 9, 1)) do
        internship_offer = create(
          :weekly_internship_offer_3eme, max_candidates: 3
        )
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        create(:weekly_internship_application,
               :approved,
               internship_offer:)
        sign_in(internship_offer.employer)

        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: {
                max_candidates: 1
              } })
        error_message = 'Nbr. max de candidats accueillis sur le stage : Impossible de réduire le ' \
                        'nombre de places de cette offre de stage car vous avez déjà accepté ' \
                        "plus de candidats que vous n'allez leur offrir de places."
        assert_response :bad_request
        assert_select('.fr-alert.fr-alert--error', text: error_message)
      end
    end

    test 'PATCH #update as statistician owning internship_offer updates internship_offer' do
      skip 'leak suspicion'
      travel_to(Date.new(2024, 9, 1)) do
        internship_offer = create(:weekly_internship_offer_2nde, :with_public_group)
        statistician = create(:statistician)
        internship_offer.update(employer_id: statistician.id)
        new_title = 'new title'
        sign_in(statistician)
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: {
                title: new_title,
                daily_hours: { 'lundi' => %w[10h 12h] }
              } }.deep_symbolize_keys)
        assert_redirected_to(dashboard_internship_offers_path(origine: 'dashboard'),
                             'redirection should point to updated offer')

        assert_equal(new_title,
                     internship_offer.reload.title,
                     'can\'t update internship_offer title')
        assert_equal %w[10h 12h], internship_offer.reload.daily_hours['lundi']
      end
    end

    test 'PATCH #update as employer owning internship_offer can publish/unpublish offer' do
      skip 'leak suspicion'
      travel_to(Date.new(2025, 3, 1)) do
        internship_offer = create(:weekly_internship_offer_2nde, :published, published_at: 50.days.ago)
        internship_offer.update_columns(published_at: 50.days.ago)
        assert_equal 50.days.ago, internship_offer.published_at
        puts "internship_offer.published_at: #{internship_offer.published_at}"
        puts ''
        new_published_at = 2.days.ago
        sign_in(internship_offer.employer)
        assert_changes -> { internship_offer.reload.published_at.day },
                       from: internship_offer.published_at.day,
                       to: new_published_at.day do
          patch(dashboard_internship_offer_path(internship_offer.to_param),
                params: { internship_offer: { published_at: new_published_at } })
        end
      end
    end

    test 'PATCH #republish as employer with missing seats' do
      travel_to(Date.new(2025, 9, 1)) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer_2nde,
                                  employer:,
                                  max_candidates: 1)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer:)

        internship_application.employer_validate!
        internship_application.approve!

        assert_equal 0, internship_offer.reload.remaining_seats_count
        assert internship_offer.need_to_be_updated?

        sign_in(employer)
        patch republish_dashboard_internship_offer_path(
          internship_offer.to_param
        )
        follow_redirect!
        assert_select(
          'span#alert-text',
          text: "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage"
        )
        refute internship_offer.reload.published?
      end
    end

    test 'PATCH #republish as employer with selectable_from_now_until_end_of_school_year and seats' do
      skip 'test is brittle but works when run alone' unless ENV.fetch('RUN_BRITTLE_TEST', false) == 'true'
      # travel_to Date.new(2024, 9, 1) do
      #   weeks = Week.selectable_from_now_until_end_of_school_year.first(1)
      # end
      travel_to Date.new(2023, 10, 1) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer_2nde,
                                  employer:,
                                  max_candidates: 1)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer:)
        internship_application.employer_validate!
        internship_application.approve!
        assert_equal 0, internship_offer.reload.remaining_seats_count
        refute internship_offer.published? # self.reload.published_at.nil?

        sign_in(employer)
        patch republish_dashboard_internship_offer_path(
          internship_offer.to_param
        )
        follow_redirect!
        assert_select(
          'span#alert-text',
          text: "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage"
        )
        refute internship_offer.reload.published?
      end
    end

    test 'PATCH as employer while removing weeks where internship_applications were formerly created' do
      travel_to Date.new(2024, 10, 1) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer_2nde,
                                  employer:,
                                  max_candidates: 1)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer:)
        sign_in(employer)
        patch dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: internship_offer.attributes.merge!({ week_ids: [weeks.second.id] }) }
        refute internship_application.canceled_by_employer?
        # assert internship_application.reload.canceled_by_employer?
      end
    end

    test 'PATCH #update as employer owning internship_offer swiches offer from troisieme to seconde' do
      # purpose of test is to check the weeks are updated
      travel_to Date.new(2024, 9, 1) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer_3eme,
                                  weeks: Week.troisieme_selectable_weeks,
                                  employer:,
                                  max_candidates: 1)
        create(:sector, name: 'Fonction publique')
        sign_in(employer)
        switching_params = {
          grade_college: '0',
          grade_2e: '1',
          max_candidates: 20,
          max_students_per_group: 20,
          week_ids: [SchoolTrack::Seconde.first_week.id],
          period: '11'
        }
        params = { internship_offer: internship_offer.attributes.merge!(switching_params) }
        patch dashboard_internship_offer_path(internship_offer.to_param), params: params
        assert_redirected_to dashboard_internship_offers_path(origine: 'dashboard')
        assert_equal 20, internship_offer.reload.max_candidates
        assert_equal 20, internship_offer.max_students_per_group
        assert_equal [Grade.seconde], internship_offer.grades
        assert_equal SchoolTrack::Seconde.first_week.id, internship_offer.weeks.first.id
        assert_equal 1, internship_offer.weeks.count
      end
    end
  end
end
