module Dto
  class MultiPlanningAdapter < PlanningAdapter
    
    def manage_planning_associations
      manage_grades
      manage_weeks
      self
    end
  end
end

