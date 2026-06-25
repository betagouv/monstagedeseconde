# frozen_string_literal: true

module Abilities
  module StatisticianAbility
    def statistician_abilities(user:)
      common_to_all_statisticians(user:)

      can :show, :api_token

      can %i[create], InternshipOccupation
      can %i[create], MultiActivity

      can %i[index], Acl::Reporting, &:allowed?

      can %i[index_and_filter], Reporting::InternshipOffer
      can %i[ see_reporting_dashboard
              see_dashboard_administrations_summary
              see_dashboard_department_summary
              export_reporting_dashboard_data
              see_dashboard_associations_summary
              export_reporting_school], User
      can :view, :department
    end

    def education_statistician_abilities(user:)
      common_to_all_statisticians(user:)
      can %i[create], InternshipOccupation
      can %i[create], MultiActivity
      can %i[index], Acl::Reporting, &:allowed?

      can %i[index_and_filter], Reporting::InternshipOffer
      can %i[ see_reporting_dashboard
              see_dashboard_administrations_summary
              see_dashboard_department_summary
              export_reporting_dashboard_data
              see_dashboard_associations_summary], User
      can :view, :department
    end

    def ministry_statistician_abilities(user:)
      common_to_all_statisticians(user:)

      can %i[create], InternshipOccupation do |internship_occupation|
        internship_occupation.group.in?(user.ministries) && internship_occupation.is_public
      end
      can %i[create], MultiActivity

      can %i[index_and_filter], Reporting::InternshipOffer
      can :read, Group
      can %i[index], Acl::Reporting, &:ministry_statistician_allowed?
      can %i[ export_reporting_dashboard_data
              see_ministry_dashboard
              see_dashboard_associations_summary ], User
    end

    def academy_statistician_abilities(user:)
      common_to_all_statisticians(user:)

      can %i[index_and_filter], Reporting::InternshipOffer
      can :read, Group
      can %i[index], Acl::Reporting, &:allowed?
      can %i[ see_reporting_dashboard
              see_dashboard_administrations_summary
              see_dashboard_department_summary
              export_reporting_dashboard_data
              see_dashboard_associations_summary ], User
    end

    def academy_region_statistician_abilities(user:)
      common_to_all_statisticians(user:)

      can %i[index_and_filter], Reporting::InternshipOffer
      can :read, Group
      can %i[index], Acl::Reporting, &:allowed?
      can %i[ export_reporting_dashboard_data
              see_dashboard_administrations_summary
              see_dashboard_department_summary
              export_reporting_dashboard_data
              see_dashboard_associations_summary ], User
    end

    private

    def common_to_all_statisticians(user:)
      as_employers_like(user:)
      as_employers_signatory_abilities(user:) if user.agreement_signatorable?
      can %i[
        choose_statistician_type
        supply_offers
        subscribe_to_webinar,
        show_modal_info
      ], User

      can %i[see_reporting_dashboard
             see_dashboard_administrations_summary], User
    end
  end
end
