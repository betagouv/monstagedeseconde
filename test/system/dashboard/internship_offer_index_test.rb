# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferIndexTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  test 'cron set aasm_state to need_to_be_updated when necessary' do
    employer = create(:employer)
    old_internship_offer = nil
    travel_to Date.new(2024, 10, 1) do
      old_internship_offer = create(:weekly_internship_offer_2nde, :both_weeks, employer:,
                                                                                internship_offer_area_id: employer.current_area_id)
    end
    travel_to Date.new(2025, 10, 1) do
      internship_offer = create(:weekly_internship_offer_2nde, :both_weeks, employer:,
                                                                            internship_offer_area_id: employer.current_area_id)
      assert_equal Date.new(2026, 6, 26), internship_offer.last_date
      assert old_internship_offer.last_date < Time.now.utc

      sign_in(employer)

      InternshipOffer.stub :nearby, InternshipOffer.all do
        visit dashboard_internship_offers_path

        assert_presence_of(internship_offer:)
        assert_presence_of(internship_offer: old_internship_offer)

        within("#toggle_status_internship_offers_weekly_framed_#{internship_offer.id}") do
          find('.label', text: 'Publié')
        end
        within("#toggle_status_internship_offers_weekly_framed_#{old_internship_offer.id}") do
          find('.label', text: 'Publié')
        end

        InternshipOffers::WeeklyFramed.update_older_internship_offers

        visit dashboard_internship_offers_path

        within("#toggle_status_#{dom_id(internship_offer)}") do
          find('.label', text: 'Publié')
        end
        within("#toggle_status_#{dom_id(old_internship_offer)}") do
          find('.label', text: 'Masqué')
        end
      end
    end
  end

  test 'tabs test(still todo)' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer_2nde, employer:)
    sign_in(employer)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit dashboard_internship_offers_path
      end
    end
  end

  test 'unpublish navigation and republish after' do
    travel_to Date.new(2021, 10, 1) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde, employer:,
                                                               internship_offer_area_id: employer.current_area_id)
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        assert internship_offer.published?
        InternshipOffers::WeeklyFramed.update_older_internship_offers
        assert internship_offer.reload.published?
        visit dashboard_internship_offers_path
        within("#toggle_status_#{dom_id(internship_offer)}") do
          find('.label', text: 'Publié')
          find("a[rel='nofollow'][data-method='patch']").click # this unpublishes the internship_offer
        end

        find('h2.h4', text: 'Les offres')
        sleep 0.05
        assert internship_offer.reload.unpublished?

        within("#toggle_status_#{dom_id(internship_offer)}") do
          find('.label', text: 'Masqué')
        end
        assert internship_offer.reload.unpublished?
        assert_nil internship_offer.published_at

        # ----------------------------
        # republish
        # ----------------------------
        within("#toggle_status_#{dom_id(internship_offer)}") do
          find("a[rel='nofollow'][data-method='patch']").click # this republishes the internship_offer
        end
        find('h2.h4', text: 'Les offres')
        sleep 0.05
        assert internship_offer.reload.published?
        refute internship_offer.published_at.nil?
      end
    end
  end

  test 'publish navigation when drafted and no updates are necessary' do
    skip 'This test is not working on CI, but works locally' if ENV['CI'] == 'true'
    travel_to Date.new(2024, 10, 1) do
      employer = create(:employer)
      internship_offer = create(
        :weekly_internship_offer_2nde,
        employer:,
        internship_offer_area_id: employer.current_area_id
      )
      internship_offer.update_columns(published_at: nil, updated_at: Time.now - 1.day, aasm_state: 'drafted')
      assert_equal 'drafted', internship_offer.aasm_state
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          visit dashboard_internship_offers_path
          within("#toggle_status_#{dom_id(internship_offer)}") do
            find('.label', text: 'Masqué')
            # following leads to intenship offer detail page because no updates are necessary
            find("a[title='Publier / Masquer']").click
          end

          find('h1.h3.text-dark', text: internship_offer.title)

          within('.fr-container .fat-line-below .col-8.d-print-none') do
            find('p.fr-badge.fr-badge--new', text: 'BROUILLON')
          end
          assert_equal 'drafted', internship_offer.aasm_state
        end
      end
    end
  end

  test 'publish navigation when max_candidates updates are necessary' do
    skip 'works locally but not on CI' if ENV['CI'] == 'true'
    employer = create(:employer)
    internship_offer = nil
    travel_to Date.new(2024, 10, 1) do
      internship_offer = create(
        :weekly_internship_offer_2nde,
        max_candidates: 1,
        employer:,
        internship_offer_area_id: employer.current_area_id
      )
      create(:weekly_internship_application, :approved, internship_offer:)
    end
    travel_to Date.new(2025, 9, 1) do
      internship_offer.need_update! # due to cron job and max_candidates too low
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          refute internship_offer.published?
          visit dashboard_internship_offers_path
          within("#toggle_status_#{dom_id(internship_offer)}") do
            find('.label', text: 'Masqué')
            find("label.fr-toggle__label[for='toggle-#{internship_offer.id}']") # this publishes the internship_offer
            execute_script("document.getElementById('axe-toggle-#{internship_offer.id}').closest('form').submit()")
          end

          refute internship_offer.reload.published?

          find 'h1.h2', text: 'Modifier une offre de stage'
          find 'span#alert-text',
               text: "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage"
        end
      end
    end
  end
end
