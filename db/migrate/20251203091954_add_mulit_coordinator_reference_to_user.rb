class AddMulitCoordinatorReferenceToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :multi_activity, null: true, foreign_key: true
  end
end
