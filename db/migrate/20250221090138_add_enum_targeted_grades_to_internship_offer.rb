class AddEnumTargetedGradesToInternshipOffer < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TYPE targeted_grades
             AS ENUM ('seconde_only',
                      'troisieme_only',
                      'quatrieme_only',
                      'troisieme_or_quatrieme',
                      'seconde_troisieme_or_quatrieme');
    SQL
    add_column :internship_offers, :targeted_grades, :targeted_grades, default: 'seconde_only'
    add_index :internship_offers, :targeted_grades
  end

  def down
    remove_index :internship_offers, :targeted_grades
    remove_column :internship_offers, :targeted_grades
    execute <<-SQL
      DROP TYPE targeted_grades
    SQL
  end
end
