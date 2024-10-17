class WithdrawPeriodFromInternshipOffer < ActiveRecord::Migration[7.1]
  def change
    remove_column :internship_offers, :period, :integer
  end
end
