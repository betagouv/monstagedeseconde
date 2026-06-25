class AddLowPrioritiesActionTypes < ActiveRecord::Migration[8.1]
  def up
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'candidate_chose_another_internship';"
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'candidate_restored_by_student';"
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'canceled_internship_application';"
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'agreement_signed_by_another';"
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'internship_application_transfered';"
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'internship_offer_unpublished';"
    execute "ALTER TYPE action_type ADD VALUE IF NOT EXISTS 'internship_offer_removed';"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
