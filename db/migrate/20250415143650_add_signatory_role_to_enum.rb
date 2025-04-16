class AddSignatoryRoleToEnum < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TYPE agreement_signatory_role ADD VALUE 'teacher';
      ALTER TYPE agreement_signatory_role ADD VALUE 'main_teacher';
    SQL
  end

  def down
  end
end
