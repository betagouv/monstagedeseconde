class PlanningGrade < ApplicationRecord
  # Relations
  belongs_to :grade # , counter_cache: true
  belongs_to :planning # , counter_cache: true
end
