# frozen_string_literal: true

require 'test_helper'

# Stage partagé (MGF-1772) : 1 candidature retenue sur une offre partagée doit
# déboucher sur 2 conventions distinctes, une par structure d'accueil.
class InternshipApplicationSharedAgreementsTest < ActiveSupport::TestCase
  setup do
    # On se place en milieu d'année scolaire pour que les semaines de seconde
    # (juin) soient sélectionnables par les factories (suite sensible à la date).
    travel_to(Time.zone.local(2026, 1, 15))
  end

  teardown { travel_back }

  def build_shared_offer(offer_attrs = {})
    multi_corporation = create(:shared_multi_corporation)
    create(:multi_internship_offer, { multi_corporation: multi_corporation }.merge(offer_attrs))
  end

  def build_validated_application(offer)
    create(:multi_internship_application,
           aasm_state: :validated_by_employer,
           weeks: SchoolTrack::Seconde.both_weeks,
           internship_offer: offer)
  end

  test 'create_agreement génère 2 conventions distinctes, une par structure' do
    offer = build_shared_offer
    application = build_validated_application(offer)

    assert_equal 2, offer.corporations.count

    assert_difference -> { InternshipAgreement.kept.count }, 2 do
      application.create_agreement
    end

    agreements = application.internship_agreements.kept
    assert_equal 2, agreements.count
    assert agreements.all? { |a| a.is_a?(InternshipAgreements::MultiInternshipAgreement) }
    assert_equal offer.corporations.pluck(:id).sort, agreements.map(&:corporation_id).sort
    assert agreements.all?(&:shared_offer_agreement?)
    assert agreements.none?(&:legacy_multi?)
  end

  test 'chaque convention est remplie depuis SA structure (représentant, tuteur, siret)' do
    offer = build_shared_offer
    application = build_validated_application(offer)
    application.create_agreement

    offer.corporations.each do |corporation|
      agreement = application.internship_agreements.kept.find_by(corporation_id: corporation.id)
      assert_not_nil agreement
      assert_equal corporation.corporation_name, agreement.employer_name
      assert_equal corporation.employer_email, agreement.employer_contact_email
      assert_equal corporation.employer_name, agreement.organisation_representative_full_name
      assert_equal corporation.tutor_name, agreement.tutor_full_name
      assert_equal corporation.tutor_email, agreement.tutor_email
      assert_equal corporation.siret, agreement.siret
    end
  end

  test 'les 2 conventions ont des date_range distincts (1 semaine chacune)' do
    offer = build_shared_offer
    application = build_validated_application(offer)
    application.create_agreement

    ranges = application.internship_agreements.kept.map(&:date_range)
    assert_equal 2, ranges.uniq.size, "les deux conventions doivent couvrir des semaines différentes"
  end

  test "la convention de la période 2 reçoit les horaires de la seconde période s'ils diffèrent" do
    daily_hours_2 = { 'lundi' => ['10:00', '15:00'], 'mardi' => ['10:00', '15:00'],
                      'mercredi' => ['10:00', '15:00'], 'jeudi' => ['10:00', '15:00'],
                      'vendredi' => ['10:00', '15:00'] }
    offer = build_shared_offer(daily_hours_2: daily_hours_2)
    application = build_validated_application(offer)
    application.create_agreement

    corp1 = offer.corporations.find_by(period: 1)
    corp2 = offer.corporations.find_by(period: 2)
    agreement_1 = application.internship_agreements.kept.find_by(corporation_id: corp1.id)
    agreement_2 = application.internship_agreements.kept.find_by(corporation_id: corp2.id)

    assert_equal offer.daily_hours, agreement_1.daily_hours
    assert_equal daily_hours_2, agreement_2.daily_hours
    assert_not_equal agreement_1.daily_hours, agreement_2.daily_hours
  end

  test 'create_agreement est idempotent par structure' do
    offer = build_shared_offer
    application = build_validated_application(offer)
    application.create_agreement

    assert_no_difference -> { InternshipAgreement.kept.count } do
      application.create_agreement
    end
  end

  test "l'unicité autorise 2 conventions par candidature mais 1 seule par structure" do
    offer = build_shared_offer
    application = build_validated_application(offer)
    application.create_agreement

    corporation = offer.corporations.first
    duplicate = InternshipAgreements::MultiInternshipAgreement.new(
      internship_application: application,
      corporation: corporation
    )
    duplicate.skip_validations_for_system = true
    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :internship_application_id
  end
end
