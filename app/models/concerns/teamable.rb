# frozen_string_literal: true

# Every type of employer should be able to create a team and an internship offer area
# This module gathers the common methods for all employers_likes.
module Teamable
  extend ActiveSupport::Concern

  included do
    include InternshipOfferAreable

    has_many :team_member_invitations,
             dependent: :destroy,
             foreign_key: :inviter_id

    has_many :internship_offer_areas,
             as: :employer,
             class_name: 'InternshipOfferArea',
             foreign_key: 'employer_id',
             inverse_of: :employer

    has_many :area_notifications,
             through: :internship_offer_areas,
             as: :employer,
             dependent: :destroy

    has_many :internship_offers,
             through: :internship_offer_areas,
             source: :employer,
             source_type: 'User',
             class_name: 'InternshipOffer',
             foreign_key: 'employer_id'

    has_many :kept_internship_offers,
             -> { merge(InternshipOffer.kept.where.not(type: 'InternshipOffers::Api')) },
             class_name: 'InternshipOffer',
             foreign_key: 'employer_id'


    has_many :internship_applications, through: :kept_internship_offers
    has_many :internship_agreements, through: :internship_applications

    scope :with_mono_internship_agreements, -> {
      joins(:internship_agreements)
        .merge(InternshipAgreements::MonoInternshipAgreement.all)
    }
    scope :with_multi_internship_agreements, -> {
      joins(:internship_agreements)
        .merge(InternshipAgreements::MultiInternshipAgreement.all)
    }

    def valid_transition?(transition)
      %w[read! read employer_validate! employer_validate transfer! transfer reject! reject cancel_by_employer!
         cancel_by_employer].include?(transition)
    end

    def personal_internship_offers
      InternshipOffer.where(employer_id: id)
    end

    def team_internship_offers
      InternshipOffer.where(employer_id: team_members_ids)
    end

    def internship_offers
      team_internship_offers.where(internship_offer_area_id: fetch_current_area_id)
    end

    def mono_internship_agreements
      internship_agreements.merge(InternshipAgreements::MonoInternshipAgreement.all)
    end

    def anonymize(send_email: true)
      InternshipOffer.where(employer_id: id).each do |offer|
        offer.anonymize
      end
      destroy_area_and_notifications_with_anonymizing
      team.remove_member if team.alive?
      super(send_email:)
    end

    def destroy_area_and_notifications_with_anonymizing
      internship_offer_areas.each do |area|
        area.area_notifications.where(user_id: id).to_a.each do |notif|
          notif.destroy
        end
        area.soft_destroy
      end
    end

    def internship_agreements
      return super unless team.alive?

      internship_applications = InternshipApplication.where(internship_offer: internship_offers)
      InternshipAgreement.kept.where(internship_application: internship_applications)
    end

    def team_pending_agreements_actions_count
      common_team_action_count(:pending_agreements_actions_count)
    end


    def team_pending_multi_agreements_actions_count
      common_team_action_count(:pending_multi_agreements_actions_count)
    end

    def pending_agreements_actions_count
      common_action_count(internship_agreements.mono.kept)
    end

    def pending_multi_agreements_actions_count
      common_action_count(internship_agreements.multi.kept)
    end

    def common_team_action_count(method)
      return send(method) if team.not_exists?

      team.db_members.inject(0) do |sum, member|
        sum + member.send(method)
      end
    end

    def common_action_count(agreements)
      part1 = agreements.where(aasm_state: InternshipAgreement::EXPECTED_ACTION_FROM_EMPLOYER_STATES).count
      agreements_to_be_signed = agreements.where(aasm_state: %i[signatures_started validated])
      signed_count = agreements_to_be_signed.select {|agreement| agreement.signature_signed_by_role?("employer")}.count
      part1 + (agreements_to_be_signed.count - signed_count)
    end

    def internship_offer_ids_by_area(area_id:)
      Rails.cache.fetch("offer_ids_by_area_#{area_id}-#{team_member_ids.join('-')}", expires_in: 12.hours) do
        InternshipOffer.kept
                      .where(employer_id: team_members_ids)
                      .where(internship_offer_area_id: area_id || fetch_current_area_id)
                      .pluck(:id)
      end
    end

    def internship_applications_by_area(area_id:)
      offer_ids = internship_offer_ids_by_area(area_id:)
      return InternshipApplication.none if offer_ids.empty?

      InternshipApplication.where(internship_offer_id: offer_ids)
    end

    def internship_applications_by_area_and_states(area_id:, aasm_state:)
      offer_ids = internship_offer_ids_by_area(area_id:)
      return InternshipApplication.none if offer_ids.empty?

      InternshipApplication.where(internship_offer_id: offer_ids)
                           .where(aasm_state:)
    end

    def internship_applications_by_states(aasm_state:)
      offer_ids = team_internship_offers.kept.pluck(:id)
      return InternshipApplication.none if offer_ids.empty?

      InternshipApplication.where(internship_offer_id: offer_ids)
                           .where(aasm_state:)
    end

    def internship_offers_by_area(area_id:)
      offer_ids = internship_offer_ids_by_area(area_id:)
      return InternshipOffer.none if offer_ids.empty?

      InternshipOffer.kept.where(id: offer_ids)
    end

    def internship_offers_by_team
      InternshipOffer.kept
                     .where(employer_id: team_members_ids)
    end

    def team
      Team.new(self)
    end

    def team_id
      team.team_owner_id || id
    end

    def team_members_ids
      member_ids = team.team_members.pluck(:member_id).compact
      member_ids.empty? ? [id] : member_ids
    end

    def db_team_members
      users = []
      team_members_ids.each do |user_id|
        users << User.find_by(id: user_id)
      end
      users.compact
    end

    def came_from_invitation?
      TeamMemberInvitation.where(invitation_email: email).any?
    end

    def pending_invitation_to_a_team
      TeamMemberInvitation.with_pending_invitations.find_by(invitation_email: email)
    end

    def pending_invitations_to_my_team
      TeamMemberInvitation.with_pending_invitations.where(inviter_id: team_id)
    end

    def refused_invitations
      TeamMemberInvitation.refused_invitation.where(inviter_id: team_id)
    end
  end
end
