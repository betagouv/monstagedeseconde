# frozen_string_literal: true

require 'test_helper'
module Users
  class EmployerTest < ActiveSupport::TestCase
    include TeamAndAreasHelper
    test 'employer.after_sign_in_path redirects to internship_offers_path' do
      employer = build(:employer)
      assert_equal(employer.after_sign_in_path,
                   Rails.application.routes.url_helpers.dashboard_internship_offers_path)
    end

    test '(rails6.1 upgrade) employer.kept_internship_offers' do
      employer = create(:employer)
      kept_internship_offer = create(:weekly_internship_offer, employer: employer)
      discarded_internship_offer = create(:weekly_internship_offer, employer: employer)
      discarded_internship_offer.discard

      assert_equal 1, employer.kept_internship_offers.count
      assert_includes employer.kept_internship_offers, kept_internship_offer
      refute_includes employer.kept_internship_offers, discarded_internship_offer
    end

    test '#obfuscated_phone_number' do
      employer = build(:employer, phone: '+330601020304')
      assert_equal '+33 6 ** ** ** 04', employer.obfuscated_phone_number
    end

    test '(rails6.1 upgrade) employer.internship_applications' do
      employer = create(:employer)
      kept_internship_offer = create(:weekly_internship_offer, employer: employer)
      discarded_internship_offer = create(:weekly_internship_offer, employer: employer)
      kept_internship_application = create(:weekly_internship_application, internship_offer: kept_internship_offer)
      discarded_internship_application = create(:weekly_internship_application, internship_offer: discarded_internship_offer)

      discarded_internship_offer.discard

      assert_equal 1, employer.internship_applications.count
      assert_includes employer.internship_applications, kept_internship_application
      refute_includes employer.internship_applications, discarded_internship_application
    end

    test '#already_signed?' do
      internship_agreement_1 = create(:internship_agreement)
      internship_agreement_2 = create(:internship_agreement)
      employer = internship_agreement_1.employer
      refute employer.already_signed?(internship_agreement_id: internship_agreement_1.id)
      refute employer.already_signed?(internship_agreement_id: internship_agreement_2.id)
      create(:signature,
             internship_agreement: internship_agreement_1,
             signatory_role: :employer,
             user_id: employer.id
            )
      assert employer.already_signed?(internship_agreement_id: internship_agreement_1.id)
      refute employer.already_signed?(internship_agreement_id: internship_agreement_2.id)
    end

    test '#internship_offers with a team with a one or more area' do
      employer_1 = create(:employer)
      assert_equal 1, InternshipOfferArea.count
      area = employer_1.current_area
      employer_2 = create(:employer)
      assert_equal 2, InternshipOfferArea.count
      internship_offer_1 = create_internship_offer_visible_by_two(employer_1, employer_2)
      internship_offer_2 = create_internship_offer_visible_by_two(employer_2, employer_1)
      assert_equal 2, TeamMemberInvitation.count
      assert_equal [internship_offer_1.id, internship_offer_2.id].sort, employer_2.internship_offers.to_a.map(&:id).sort
      assert_equal [internship_offer_1.id, internship_offer_2.id].sort, employer_1.internship_offers.to_a.map(&:id).sort
      internship_offer_3 = create(:weekly_internship_offer,
                                  employer: employer_1,
                                  internship_offer_area_id: create(:area).id)
      assert_equal [internship_offer_1.id, internship_offer_2.id].sort,
                    employer_2.internship_offers.to_a.map(&:id).sort
      assert_equal [internship_offer_1.id, internship_offer_2.id].sort,
                    employer_1.internship_offers.to_a.map(&:id).sort
    end

    test '#anonymize when in a team with internship_offers' do
      employer_1 = create(:employer)
      original_area = employer_1.current_area
      employer_2 = create(:employer)
      assert_equal 2, InternshipOfferArea.count # 1 per employer
      offer = create_internship_offer_visible_by_two(employer_1, employer_2)
      assert_equal employer_1.current_area_id, employer_2.current_area_id
      assert_equal employer_1.id, offer.employer.id
      assert_equal employer_1.current_area_id, offer.internship_offer_area_id
      offer_2 = create(:weekly_internship_offer, employer: employer_2, internship_offer_area_id: employer_1.current_area_id)
      assert_equal employer_1.current_area_id, employer_2.current_area_id
      assert_equal 2, employer_1.internship_offer_areas.count
      assert_changes -> { InternshipOffer.kept.count } , from: 2, to: 1 do
        assert_changes -> { InternshipOfferArea.count  } , from: 2, to: 1 do
          employer_1.anonymize
        end
      end
      assert_equal original_area.id, employer_2.current_area_id
      assert_equal offer_2.internship_offer_area_id, employer_2.current_area_id
    end

    test '#anonymize when not in a team with internship_offers' do
      employer_1 = create(:employer)
      offer = create(:weekly_internship_offer, employer: employer_1, internship_offer_area_id: employer_1.current_area_id)
      assert_equal 1, InternshipOfferArea.count
      assert_changes -> { InternshipOffer.kept.count } , from: 1, to: 0 do
        assert_no_changes -> { InternshipOfferArea.count }  do
          employer_1.anonymize
        end
      end
    end

    test '#pending_agreements_actions_count with 1 signature by employer' do
      employer = create(:employer)
      create(:weekly_internship_offer, employer: employer)
      status_count = InternshipAgreement.aasm.states.count
      status_count.times do
        student = create(:student)
        wio = create(:weekly_internship_offer, employer: employer)
        create(
          :weekly_internship_application,
          :submitted,
          internship_offer: wio,
          student: student
        )
      end
      InternshipAgreement.aasm.states.each_with_index do |state, index|
        create(
          :internship_agreement,
          aasm_state: state.name.to_sym,
          internship_application: InternshipApplication.all.to_a[index],
        )
      end
      create(
        :signature,
        signatory_role: 'employer',
        internship_agreement_id: InternshipAgreement.find_by(aasm_state: :signatures_started).id
      )
      assert_equal 3, employer.pending_agreements_actions_count
      # 1 for :draft
      # 1 for :started_by_employer
      # 1 for :validated
      # 0 for :signatures_started
    end

    test "#pending_agreements_actions_count with 1 signature by school_manager" do
      employer = create(:employer)
      create(:weekly_internship_offer, employer: employer)
      status_count = InternshipAgreement.aasm.states.count
      status_count.times do
        student = create(:student)
        wio = create(:weekly_internship_offer, employer: employer)
        create(
          :weekly_internship_application,
          :submitted,
          internship_offer: wio,
          student: student
        )
      end
      InternshipAgreement.aasm.states.each_with_index do |state, index|
        create(
          :internship_agreement,
          aasm_state: state.name.to_sym,
          internship_application: InternshipApplication.all.to_a[index],
        )
      end
      create(
        :signature,
        signatory_role: 'school_manager',
        internship_agreement_id: InternshipAgreement.find_by(aasm_state: :signatures_started).id
      )
      assert_equal 4, employer.pending_agreements_actions_count
      # 1 for :draft
      # 1 for :started_by_employer
      # 1 for :validated
      # 1 for :signatures_started
    end
  end
end
