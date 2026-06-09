# frozen_string_literal: true

class Ability
  include CanCan::Ability
  include Abilities::VisitorAbility
  include Abilities::GodAbility
  include Abilities::StudentAbility
  include Abilities::EmployerAbility
  include Abilities::OperatorAbility
  include Abilities::StatisticianAbility
  include Abilities::SchoolManagementAbility
  include Abilities::SharedAbility

  def initialize(user = nil)
    if user.present?
      if user.god?                     then god_abilities
      elsif user.student?              then student_abilities(user:)
      elsif user.employer?             then employer_abilities(user:)
      elsif user.operator?             then operator_abilities(user:)
      elsif user.is_a?(Users::SchoolManagement)
        common_school_management_abilities(user:)
        school_manager_abilities(user:) if user.school_manager?
      elsif user.is_a?(Users::PrefectureStatistician) then statistician_abilities(user:)
      elsif user.is_a?(Users::EducationStatistician)  then education_statistician_abilities(user:)
      elsif user.is_a?(Users::MinistryStatistician)   then ministry_statistician_abilities(user:)
      elsif user.is_a?(Users::AcademyStatistician)    then academy_statistician_abilities(user:)
      elsif user.is_a?(Users::AcademyRegionStatistician) then academy_region_statistician_abilities(user:)
      end

      shared_signed_in_user_abilities(user:)
    else
      visitor_abilities
    end
  end
end
