class UpdateSignatoryRole < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TYPE agreement_signatory_role ADD VALUE 'other';
      ALTER TYPE agreement_signatory_role ADD VALUE 'cpe';
      ALTER TYPE agreement_signatory_role ADD VALUE 'admin_officer';
    SQL
  end

  def down
  end
end
