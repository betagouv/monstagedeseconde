class RemoveRoleFromInvitation < ActiveRecord::Migration[7.1]
  def change
    Invitation.delete_all
    remove_column :invitations, :role, :string, limit: 50, null: false, default: 'other'
  end
end
