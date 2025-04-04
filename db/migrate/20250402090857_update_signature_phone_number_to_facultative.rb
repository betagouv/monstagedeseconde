class UpdateSignaturePhoneNumberToFacultative < ActiveRecord::Migration[7.1]
  def change
    change_column :signatures, :signature_phone_number, :string, null: true
  end
end
