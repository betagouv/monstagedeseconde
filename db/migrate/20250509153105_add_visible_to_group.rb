class AddVisibleToGroup < ActiveRecord::Migration[7.1]
  def up
    remove_column :groups, :visible if column_exists?(:groups, :visible)
    add_column :groups, :visible, :boolean, default: true
    Group.find_by(name: 'Ministère de l’Enseignement supérieur et de la Recherche')&.tap do |group|
      group.update_columns(visible: false)
    end
    remove_index :groups, :visible if index_exists?(:groups, :visible)
    add_index :groups, :visible
  end

  def down
    remove_index :groups, :visible if index_exists?(:groups, :visible)
    return unless column_exists?(:groups, :visible)

    remove_column :groups, :visible
  end
end
