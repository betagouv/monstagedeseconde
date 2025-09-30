class AddStudentAndRepresentativeRoleToSignatoryRole < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TYPE agreement_signatory_role ADD VALUE 'student';
      ALTER TYPE agreement_signatory_role ADD VALUE 'student_legal_representative';
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel IN ('student', 'student_legal_representative')
      AND enumtypid = 'agreement_signatory_role'::regtype;
    SQL
  end
end
