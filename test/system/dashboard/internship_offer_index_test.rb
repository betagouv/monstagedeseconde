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
    skip 'This test is not working on CI, but works locally' if ENV['CI'] == 'true'
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
        find('.label', text: "Archivée. Dupliquez l'annonce pour la republier")

        assert internship_offer.published?
        assert old_internship_offer.published?

        InternshipOffers::WeeklyFramed.update_older_internship_offers

        assert internship_offer.reload.published?
        assert old_internship_offer.reload.unpublished?
      end
    end
  end

  test 'archived offer shows archived badge and duplicate button in index' do
    travel_to(Date.new(2026, 6, 1)) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer:,
                                internship_offer_area_id: employer.current_area_id)
      internship_offer.update_columns(
        aasm_state: 'unpublished',
        published_at: nil,
        first_date: 2.days.ago,
        last_date: 1.day.ago
      )

      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        visit dashboard_internship_offers_path
        assert_selector '.label', text: "Archivée. Dupliquez l'annonce pour la republier"
        assert_selector 'a.test-duplicate-button'
      end
    end
  end

  test 'archived offer shows archived badge and explanatory text on show page' do
    travel_to(Date.new(2026, 6, 1)) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer:,
                                internship_offer_area_id: employer.current_area_id)
      internship_offer.update_columns(
        aasm_state: 'unpublished',
        published_at: nil,
        first_date: 2.days.ago,
        last_date: 1.day.ago
      )

      sign_in(employer)
      visit internship_offer_path(internship_offer, origine: 'dashboard')
      assert_selector 'p.fr-badge', text: /offre archivée/i
      assert_selector '.label', text: "Archivée. Dupliquez l'annonce pour la republier"
      assert_selector 'a.test-duplicate-button'
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
    travel_to Date.new(2025, 3, 1) do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde,
                                employer:,
                                internship_offer_area_id: employer.current_area_id)
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        # published
        assert internship_offer.published?
        InternshipOffers::WeeklyFramed.update_older_internship_offers
        assert internship_offer.reload.published?
        visit dashboard_internship_offers_path
        assert_selector '.label', text: 'Publié'

        # Mask it
        page.execute_script(<<~JS)
          document.querySelector("#toggle_status_#{dom_id(internship_offer)} form").requestSubmit();
        JS
        assert_selector ".label", text: "Masqué"
        assert_nil internship_offer.reload.published_at
        assert internship_offer.unpublished?

        # republish
        page.execute_script(<<~JS)
          document.querySelector("#toggle_status_#{dom_id(internship_offer)} form").requestSubmit();
        JS
        assert_selector ".label", text: "Publié"
        assert internship_offer.reload.published?
        refute internship_offer.published_at.nil?
      end
    end
  end

  test 'publish navigation when updates are necessary' do
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
      InternshipOffers::WeeklyFramed.update_older_internship_offers # due to cron job and max_candidates too low
      sign_in(employer)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          refute internship_offer.reload.published?
          visit dashboard_internship_offers_path
          find('.label', text: "Archivée. Dupliquez l'annonce pour la republier")
        end
      end
    end
  end
end
