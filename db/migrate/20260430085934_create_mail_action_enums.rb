class CreateMailActionEnums < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      CREATE TYPE urgency_level AS ENUM ('critical', 'high', 'medium', 'low');
      CREATE TYPE action_type AS ENUM ('pending_application', 'agreement_to_complete', 'agreement_to_sign');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE action_type;
      DROP TYPE urgency_level;
    SQL
  end
end
