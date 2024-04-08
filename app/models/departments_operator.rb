class DepartmentsOperator < ApplicationRecord
  # frozen_string_literal: true

  # Attributes
  # id: integer, not null, primary key
  # department_id: integer
  # operator_id: integer
  # created_at: datetime, not null
  # updated_at: datetime, not null
  # Relationships
  belongs_to :department
  belongs_to :operator
  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :operator_id
      field :department_id
    end
    show do
      field :operator_id
      field :department_id
    end
    edit do
      field :operator_id
      field :department_id
    end
  end
end
