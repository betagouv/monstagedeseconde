# frozen_string_literal: true

module Abilities
  module GodAbility
    def god_abilities
      can :show, :account, :rebuild_review_job
      can :manage, School
      can :manage, Sector
      can :manage, NafSectorMapping
      can :manage, Academy
      can :manage, AcademyRegion
      can %i[read update export unpublish publish], InternshipOffer
      can %i[read update destroy export], InternshipApplication
      can :manage, InternshipOfferKeyword
      can :manage, Group
      can :access, :rails_admin
      can %i[read update delete discard export], InternshipOffers::Api
      can :read, :dashboard
      can :read, :kpi
      can %i[index department_filter], Acl::Reporting do |_acl|
        true
      end
      can %i[index_and_filter], Reporting::InternshipOffer
      can :manage, InternshipAgreement
      can :manage, MailActionItem
      can :manage, :digest_mailers
      can %i[ show_modal_info
              switch_user
              read
              update
              destroy
              export
              export_reporting_dashboard_data
              see_reporting_dashboard
              see_reporting_internship_offers
              see_reporting_schools
              see_reporting_associations
              see_reporting_enterprises
              see_dashboard_enterprises_summary
              see_dashboard_administrations_summary
              see_dashboard_associations_summary
              anonymize_user
              transform_user
              manage_boarding_houses], User
      can :manage, Operator
      can :read_employer_name, InternshipOffer
      can :manage, InappropriateOffer
    end
  end
end
