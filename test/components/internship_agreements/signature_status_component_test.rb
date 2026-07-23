# frozen_string_literal: true

require 'test_helper'

# Stage partagé (MGF-1772) : la colonne "Signature en ligne" affiche une ligne
# « Offreur » simple (la convention n'a qu'UNE structure), et non plus le
# compteur « Offreurs (x/y) » réservé au multi historique.
module InternshipAgreements
  class SignatureStatusComponentTest < ViewComponent::TestCase
    include FactoryBot::Syntax::Methods

    setup { travel_to(Time.zone.local(2026, 1, 15)) }
    teardown { travel_back }

    def build_shared_agreement
      multi_corporation = create(:shared_multi_corporation)
      offer = create(:multi_internship_offer, multi_corporation: multi_corporation)
      application = create(:multi_internship_application,
                           aasm_state: :validated_by_employer,
                           weeks: SchoolTrack::Seconde.both_weeks,
                           internship_offer: offer)
      application.create_agreement
      application.internship_agreements.kept.first
    end

    test 'stage partagé non signé : ligne « Offreur » grise, pas de compteur' do
      agreement = build_shared_agreement

      render_inline(SignatureStatusComponent.new(internship_agreement: agreement))

      assert_selector 'span', text: 'Offreur', count: 1
      assert_no_text 'Offreurs ('
      assert_selector 'span.fr-icon-close-line'
    end

    test 'stage partagé signé par sa structure : coche verte' do
      agreement = build_shared_agreement
      create(:corporation_internship_agreement,
             corporation: agreement.corporation,
             internship_agreement: agreement,
             signed: true)

      render_inline(SignatureStatusComponent.new(internship_agreement: agreement))

      assert_selector 'span', text: 'Offreur', count: 1
      assert_selector 'span.fr-icon-check-line', minimum: 1
    end

    test 'multi historique : le compteur « Offreurs (x/y) » est conservé' do
      agreement = create(:multi_internship_agreement, :with_corporation_signature_rows)

      render_inline(SignatureStatusComponent.new(internship_agreement: agreement))

      assert_text(/Offreurs \(0\/\d+\)/)
    end
  end
end
