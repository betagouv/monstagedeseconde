class AddAgreementSignedByAllActionType < ActiveRecord::Migration[8.1]
  def up
    execute "ALTER TYPE action_type ADD VALUE 'agreement_signed_by_all';"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
