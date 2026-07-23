# frozen_string_literal: true

require "test_helper"

# Stage partagé (MGF-1772) : le tableau des conventions affiche une colonne
# "Semaine(s) concernée(s)" et est trié par élève (les 2 conventions d'un stage
# partagé, issues de la même candidature, sont regroupées).
module Dashboard::InternshipAgreements
  class SharedIndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup { travel_to(Time.zone.local(2026, 1, 15)) }
    teardown { travel_back }

    test "l'index conventions charge avec la colonne Semaine(s) concernée(s)" do
      multi_corporation = create(:shared_multi_corporation)
      offer = create(:multi_internship_offer, multi_corporation: multi_corporation)
      application = create(:multi_internship_application,
                           aasm_state: :validated_by_employer,
                           weeks: SchoolTrack::Seconde.both_weeks,
                           internship_offer: offer)
      application.create_agreement

      assert_equal 2, application.internship_agreements.kept.count

      sign_in(offer.employer)
      get dashboard_internship_agreements_path

      assert_response :success
      assert_includes response.body, 'Semaine(s) concernée(s)'
    end

    test "l'index affiche « Offreur » (statut simple) pour les conventions partagées" do
      multi_corporation = create(:shared_multi_corporation)
      offer = create(:multi_internship_offer, multi_corporation: multi_corporation)
      application = create(:multi_internship_application,
                           aasm_state: :validated_by_employer,
                           weeks: SchoolTrack::Seconde.both_weeks,
                           internship_offer: offer)
      application.create_agreement

      sign_in(offer.employer)
      get dashboard_internship_agreements_path

      assert_response :success
      assert_select 'span', text: 'Offreur'
      assert_not_includes response.body, 'Offreurs (0/0)'
    end
  end
end
