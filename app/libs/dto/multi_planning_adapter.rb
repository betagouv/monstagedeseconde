module Dto
  class MultiPlanningAdapter < PlanningAdapter
    def join_association_name = :multi_planning_weeks

    def manage_planning_associations
      manage_grades
      manage_weeks
      self
    end
  end
end

