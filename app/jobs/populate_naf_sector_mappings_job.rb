class PopulateNafSectorMappingsJob < ApplicationJob
  queue_as :default

  def perform
    seed_path = Rails.root.join('db/seeds/01b_populate_naf_sector_mappings.rb')
    code = File.read(seed_path).sub(/call_method_with_metrics_tracking.*/, '')
    eval(code) # rubocop:disable Security/Eval
    populate_naf_sector_mappings
  end
end
