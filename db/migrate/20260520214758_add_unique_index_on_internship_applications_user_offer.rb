class AddUniqueIndexOnInternshipApplicationsUserOffer < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  INDEX_NAME = 'uniq_applications_per_user_offer'

  def up
    # A previous CONCURRENTLY build that failed (e.g. on duplicate rows) leaves an
    # INVALID index occupying the name: drop it so we can rebuild cleanly.
    remove_index :internship_applications, name: INDEX_NAME, if_exists: true, algorithm: :concurrently

    # The unique index cannot be built while duplicate (user_id, internship_offer_id)
    # rows exist: remove them first (keep the most advanced application per couple).
    dedup_duplicate_applications

    add_index :internship_applications,
              %i[user_id internship_offer_id],
              unique: true,
              algorithm: :concurrently,
              if_not_exists: true,
              name: INDEX_NAME
  end

  def down
    remove_index :internship_applications, name: INDEX_NAME, if_exists: true, algorithm: :concurrently
  end

  private

  # Mirrors lib/tasks/data_migrations/dedup_internship_applications.rake (without
  # PrettyConsole) so the migration is self-sufficient at deploy time.
  def dedup_duplicate_applications
    order = InternshipApplication::ORDERED_STATES_INDEX
    duplicate_keys = InternshipApplication
                     .group(:user_id, :internship_offer_id)
                     .having('COUNT(*) > 1')
                     .pluck(:user_id, :internship_offer_id)

    duplicate_keys.each do |user_id, offer_id|
      apps = InternshipApplication.where(user_id: user_id, internship_offer_id: offer_id).to_a
      apps.sort_by! { |a| [ -(order.index(a.aasm_state) || -1), -a.updated_at.to_i ] }
      apps.drop(1).each(&:destroy) # keep the first (most advanced state), delete the rest
      say "dedup user=#{user_id} offer=#{offer_id}: #{apps.size - 1} deleted"
    end
  end
end
