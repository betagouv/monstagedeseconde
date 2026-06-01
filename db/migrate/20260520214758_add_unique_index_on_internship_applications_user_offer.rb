class AddUniqueIndexOnInternshipApplicationsUserOffer < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :internship_applications,
              %i[user_id internship_offer_id],
              unique: true,
              algorithm: :concurrently,
              name: 'uniq_applications_per_user_offer'
  end
end
