class RemoveInternshipAgreementPresets < ActiveRecord::Migration[7.1]
  def change
    drop_table :internship_agreement_presets
  end
end
