class LimitVaryingCharactersFieldsInSize < ActiveRecord::Migration[7.1]
  def up
    change_column :organisations, :siren, :string, limit: 9
  end

  def def down 
  end
end
