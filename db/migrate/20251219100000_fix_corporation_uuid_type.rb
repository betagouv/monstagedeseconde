class FixCorporationUuidType < ActiveRecord::Migration[7.1]
  def up
    # On supprime l'ancien index s'il a réussi à être créé (peu probable vu l'erreur, mais par sécurité)
    remove_index :corporations, :uuid if index_exists?(:corporations, :uuid)
    
    # On supprime la colonne corrompue (qui contient la string littérale "gen_random_uuid()")
    remove_column :corporations, :uuid
    
    # On s'assure que l'extension est là pour la génération d'UUID
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # On recrée la colonne avec le bon type :uuid et la fonction par défaut
    add_column :corporations, :uuid, :uuid, default: "gen_random_uuid()", null: false
    
    # On remet l'index unique
    add_index :corporations, :uuid, unique: true
  end

  def down
    remove_index :corporations, :uuid if index_exists?(:corporations, :uuid)
    remove_column :corporations, :uuid
    add_column :corporations, :uuid, :string, default: 'gen_random_uuid()', null: false
    add_index :corporations, :uuid, unique: true
  end
end

