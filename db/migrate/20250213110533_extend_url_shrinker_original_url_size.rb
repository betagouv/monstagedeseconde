class ExtendUrlShrinkerOriginalUrlSize < ActiveRecord::Migration[7.1]
  def change
    change_column :url_shrinkers, :original_url, :string, limit: 650
  end
end
