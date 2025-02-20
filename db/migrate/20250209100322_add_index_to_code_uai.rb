class AddIndexToCodeUai < ActiveRecord::Migration[7.1]
  def change
    add_index :schools, :code_uai
  end
end
