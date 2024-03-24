class CreateJoinTableDepartmentOperator < ActiveRecord::Migration[7.1]
  def change
    create_join_table :departments, :operators do |t|
    t.index [:department_id, :operator_id]
    t.index [:operator_id, :department_id]
    end
  end
end
