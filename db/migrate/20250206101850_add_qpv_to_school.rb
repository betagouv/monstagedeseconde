class AddQpvToSchool < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :qpv, :boolean, default: false
    rename_column :schools, :kind, :rep_kind
  end
end
