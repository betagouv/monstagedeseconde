module StepperProxy
  module Planning
    extend ActiveSupport::Concern

    included do
      attr_accessor :all_year_long, :grad_3e4e

      has_many :planning_grades,
               dependent: :destroy,
               class_name: 'PlanningGrade',
               foreign_key: :planning_id
      has_many :grades, through: :planning_grades
    end
  end
end
