# frozen_string_literal: true

module Abilities
  module OperatorAbility
    def operator_abilities(user:)
      as_account_user(user:)
      as_employers_like(user:)

      can :choose_operator, :sign_up
      can :change, :department
      can %i[update discard], InternshipOffers::Api, employer_id: user.team_members_ids
      can :create, InternshipOffers::Api
      can :show, :api_token
      can %i[index_and_filter], Reporting::InternshipOffer
      can %i[index], Sector
      can %i[index], Acl::Reporting do |_acl|
        true
      end
      can %i[see_reporting_internship_offers
             export_reporting_dashboard_data
             see_reporting_schools
             see_reporting_enterprises
             check_his_statistics], User do
               !employers_only?
             end
      can :read_employer_name, InternshipOffer do |internship_offer|
        read_employer_name?(internship_offer:)
      end
    end
  end
end
