class RemoveIdentityModel < ActiveRecord::Migration[7.1]
  def up
    drop_table :identities, if_exists: true
  end

  def down
    create_table :identities do |t|
      t.references :user, foreign_key: true
      t.string :first_name, limit: 82
      t.string :last_name, limit: 82
      t.references :school, foreign_key: true
      t.references :class_room, foreign_key: true
      t.date :birth_date
      t.string :gender, default: 'np'
      t.string :token, limit: 50
      t.boolean :anonymized, default: false
      t.timestamps
      t.references :grade, foreign_key: true
    end
  end
end
