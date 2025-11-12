class RemoveOldCraftTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :coded_crafts, if_exists: true
    drop_table :detailed_crafts, if_exists: true
    drop_table :crafts, if_exists: true
    drop_table :craft_fields, if_exists: true
  end

  def down
    #
  end
end
