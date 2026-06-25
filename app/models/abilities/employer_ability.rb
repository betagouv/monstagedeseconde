# frozen_string_literal: true

module Abilities
  module EmployerAbility
    def employer_abilities(user:)
      as_employers_like(user:)
      as_employers_signatory_abilities(user:)
      as_account_user(user:)
      can %i[sign_with_sms choose_function], User
    end

    private

    def as_account_user(user:)
      can :show, :account
      can(:read_employer_name, InternshipOffer) do |internship_offer|
        read_employer_name?(internship_offer:)
      end
    end

    def as_employers_like(user:)
      can :subscribe_to_webinar, User do
        ENV.fetch("WEBINAR_URL", nil).present?
      end
      can %i[edit_password show_modal_info supply_offers], User
      can_manage_teams(user:)
      can_manage_areas(user:)
      can :index, :internship_offer_dashboard
      can :renew, InternshipOffer do |internship_offer|
        renewable?(internship_offer:, user:)
      end
      can :duplicate, InternshipOffer do |internship_offer|
        duplicable?(internship_offer:, user:)
      end
      can :publish, InternshipOffer do |internship_offer|
        internship_offer.employer_id == user.id &&
          internship_offer.last_date > SchoolYear::Current.new.offers_beginning_of_period
      end
      can :unpublish, InternshipOffer do |internship_offer|
        internship_offer.employer_id == user.id && internship_offer.published?
      end
      can %i[create see_tutor], InternshipOffer
      can %i[read discard], InternshipOffer, employer_id: user.team_members_ids
      can %i[update], InternshipOffer do |internship_offer|
        internship_offer.employer_id.in?(user.team_members_ids) &&
          internship_offer.has_weeks_after_school_year_start? &&
          !internship_offer.is_a?(InternshipOffers::Multi)
      end
      can %i[create], InternshipOccupation
      can %i[create], MultiActivity
      can %i[create], MultiCoordinator do |coordinator|
        coordinator.multi_activity.employer_id == user.id
      end
      can %i[create update edit], MultiCorporation do |multi_corporation|
        multi_corporation.multi_coordinator.multi_activity.employer_id == user.id
      end
      can %i[create update edit destroy], Corporation do |corporation|
        corporation.multi_corporation.multi_coordinator.multi_activity.employer_id == user.id
      end
      can %i[create], Entreprise do |entreprise|
        entreprise.internship_occupation.employer_id == user.id
      end
      can %i[create], Planning do |planning|
        planning.entreprise.internship_occupation.employer_id == user.id
      end
      can %i[update edit renew], InternshipOccupation, employer_id: user.team_members_ids
      can %i[update edit], MultiActivity, employer_id: user.team_members_ids
      can %i[update edit], MultiCoordinator do |coordinator|
        coordinator.multi_activity.employer_id.in?(user.team_members_ids)
      end
      can %i[update edit renew], Entreprise do |entreprise|
        entreprise.internship_occupation.employer_id.in?(user.team_members_ids)
      end
      can %i[update edit renew], Planning do |planning|
        planning.entreprise.internship_occupation.employer_id.in?(user.team_members_ids)
      end
      can %i[index update_multiple], InternshipApplication do |internship_applications|
        internship_applications.all? do |internship_application|
          application_related_to_team?(user:, internship_application:)
        end
      end
      can(:read_employer_name, InternshipOffer) do |internship_offer|
        read_employer_name?(internship_offer:)
      end
      can %i[show transfer update], InternshipApplication do |internship_application|
        internship_application.internship_offer.employer_id == user.id || application_related_to_team?(user:,
                                                                                                       internship_application:)
      end
    end

    def as_employers_signatory_abilities(user:)
      can :create, InternshipAgreement
      can %i[
        read
        index
        edit
        show
        update
        edit_employer_name
        edit_employer_address
        edit_employer_contact_email
        edit_internship_address
        edit_tutor_email
        edit_tutor_role
        edit_activity_scope
        edit_organisation_representative_full_name
        edit_organisation_representative_role
        edit_siret
        edit_tutor_full_name
        edit_weekly_hours
        edit_entreprise_address
        sign
        sign_internship_agreements
      ], InternshipAgreement do |agreement|
        agreement.employer.id.in?(user.team_members_ids)
      end
      can :create, Signature do |signature|
        signature.internship_agreement.internship_offer.internship_offer_area.employer_id.in?(user.team_members_ids)
      end
      can :multi_sign, InternshipAgreement do |agreement|
        agreement.employer.id.in?(user.team_members_ids) && agreement.from_multi?
      end
    end

    def can_manage_teams(user:)
      can %i[manage_teams], TeamMemberInvitation
      can %i[destroy], TeamMemberInvitation do |team_member_invitation|
        condition = if user.team.alive?
                      user.team.id_in_team?(team_member_invitation.member_id)
        else
                      user.id == team_member_invitation.inviter_id
        end
        team_member_invitation.member_id != user.id && condition
      end
    end

    def can_manage_areas(user:)
      can %i[create index], InternshipOfferArea

      can %i[update], InternshipOfferArea do |area|
        if user.team.alive?
          user.team.id_in_team?(area.employer_id)
        else
          user.id == area.employer_id
        end
      end

      can %i[destroy], InternshipOfferArea do |area|
        condition = if user.team.alive?
                      user.team.id_in_team?(area.employer_id)
        else
                      user.id == area.employer_id
        end
        user.team_areas.count > 1 && condition
      end

      can :generaly_destroy, InternshipOfferArea, user.team_areas.count > 1

      can :flip_notification, AreaNotification do |_area_notif|
        many_people_in_charge_of_area = !user.current_area.single_human_in_charge?
        current_area_notifications_are_off = !user.fetch_current_area_notification&.notify

        user.team.alive? &&
          (many_people_in_charge_of_area || current_area_notifications_are_off)
      end

      can :manage_abilities, AreaNotification do |area_notification|
        user.team.alive? &&
          area_notification.internship_offer_area.employer_id.in?(user.team_members_ids)
      end
    end
  end
end
