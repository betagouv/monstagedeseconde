require 'rake'

def populate_sectors
  Rails.application.load_tasks
  Rake::Task['data_migrations:add_sectors'].invoke
end

def populate_groups
  Group.create!(name: 'PUBLIC GROUP', is_public: true, is_paqte: false)
  Group.create!(name: 'PRIVATE GROUP', is_public: false, is_paqte: false)
  Group.create!(name: 'Carrefour', is_public: false, is_paqte: true)
  Group.create!(name: 'Engie', is_public: false, is_paqte: true)
  Group.create!(name: 'Ministère de la Justice', is_public: true, is_paqte: false)
  Group.create!(name: 'Ministère de l\'Intérieur', is_public: true, is_paqte: false)
end

call_method_with_metrics_tracking([
  :populate_groups,
  :populate_sectors])
