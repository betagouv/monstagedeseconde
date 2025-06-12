class SetAgreementSignatorableDefaultTrueOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :agreement_signatorable, from: false, to: true
  end
end
