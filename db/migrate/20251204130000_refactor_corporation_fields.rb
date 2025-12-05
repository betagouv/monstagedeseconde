class RefactorCorporationFields < ActiveRecord::Migration[7.1]
  def change
    # 1. Structure (Corporation) Fields
    rename_column :corporations, :employer_name, :corporation_name unless column_exists?(:corporations, :corporation_name)
    rename_column :corporations, :employer_address, :corporation_address unless column_exists?(:corporations, :corporation_address)
    rename_column :corporations, :city, :corporation_city unless column_exists?(:corporations, :corporation_city)
    rename_column :corporations, :zipcode, :corporation_zipcode unless column_exists?(:corporations, :corporation_zipcode)
    rename_column :corporations, :street, :corporation_street unless column_exists?(:corporations, :corporation_street)

    # 2. Internship Location Fields
    add_column :corporations, :internship_coordinates, :st_point, srid: 4326 unless column_exists?(:corporations, :internship_coordinates)

    # 3. Representative (Employer) Fields
    rename_column :corporations, :phone, :employer_phone unless column_exists?(:corporations, :employer_phone)
    add_column :corporations, :employer_name, :string unless column_exists?(:corporations, :employer_name)
    add_column :corporations, :employer_role, :string unless column_exists?(:corporations, :employer_role)
    add_column :corporations, :employer_email, :string unless column_exists?(:corporations, :employer_email)
  end
end
