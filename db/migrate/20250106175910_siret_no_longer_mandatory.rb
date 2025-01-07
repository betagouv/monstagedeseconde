class SiretNoLongerMandatory < ActiveRecord::Migration[7.1]
  def change
    change_column_null :entreprises, :siret, true
    change_column_null :internship_offers, :siret, true
  end
end
