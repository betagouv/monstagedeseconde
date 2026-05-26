# frozen_string_literal: true

class ReduceMailActionTypeValues < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE TYPE action_type_new AS ENUM (
        'pending_internship_offer',
        'pending_internship_application',
        'pending_internship_agreement'
      );

      ALTER TABLE mail_action_items
      ALTER COLUMN action_type TYPE action_type_new
      USING (
        CASE action_type::text
          WHEN 'pending_application' THEN 'pending_internship_application'
          WHEN 'candidate_chose_another_internship' THEN 'pending_internship_application'
          WHEN 'candidate_restored_by_student' THEN 'pending_internship_application'
          WHEN 'canceled_internship_application' THEN 'pending_internship_application'
          WHEN 'internship_application_transfered' THEN 'pending_internship_application'
          WHEN 'agreement_to_complete' THEN 'pending_internship_agreement'
          WHEN 'agreement_to_sign' THEN 'pending_internship_agreement'
          WHEN 'agreement_signed_by_all' THEN 'pending_internship_agreement'
          WHEN 'agreement_signed_by_another' THEN 'pending_internship_agreement'
          WHEN 'internship_offer_unpublished' THEN 'pending_internship_offer'
          WHEN 'internship_offer_removed' THEN 'pending_internship_offer'
          ELSE NULL
        END
      )::action_type_new;

      DROP TYPE action_type;
      ALTER TYPE action_type_new RENAME TO action_type;
    SQL
  end

  def down
    execute <<~SQL
      CREATE TYPE action_type_old AS ENUM (
        'pending_application',
        'agreement_to_complete',
        'agreement_to_sign',
        'agreement_signed_by_all',
        'candidate_chose_another_internship',
        'candidate_restored_by_student',
        'canceled_internship_application',
        'agreement_signed_by_another',
        'internship_application_transfered',
        'internship_offer_unpublished',
        'internship_offer_removed'
      );

      ALTER TABLE mail_action_items
      ALTER COLUMN action_type TYPE action_type_old
      USING (
        CASE action_type::text
          WHEN 'pending_internship_application' THEN 'pending_application'
          WHEN 'pending_internship_agreement' THEN 'agreement_to_sign'
          WHEN 'pending_internship_offer' THEN 'internship_offer_unpublished'
          ELSE NULL
        END
      )::action_type_old;

      DROP TYPE action_type;
      ALTER TYPE action_type_old RENAME TO action_type;
    SQL
  end
end
