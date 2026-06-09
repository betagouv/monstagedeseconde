class CreateSchoolStats < ActiveRecord::Migration[7.2]
  def change
    create_table :school_stats do |t|
      t.date :date_reference, null: false
      t.references :school, null: false, foreign_key: true
      t.integer :effectif # potentiel SYGNE ; nullable = échec SYGNE distinct d'un vrai 0
      t.integer :nb_utilisateurs, null: false, default: 0
      t.integer :nb_filles, null: false, default: 0
      t.integer :nb_garcons, null: false, default: 0

      t.timestamps
    end

    add_index :school_stats, %i[school_id date_reference], unique: true,
                                                           name: 'index_school_stats_on_school_and_date'
    add_index :school_stats, :date_reference
  end
end
