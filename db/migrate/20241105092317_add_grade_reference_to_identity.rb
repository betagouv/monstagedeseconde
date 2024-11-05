class AddGradeReferenceToIdentity < ActiveRecord::Migration[7.1]
  def change
    remove_column :identities, :grade, :string
    add_reference :identities, :grade, foreign_key: true
  end
end
