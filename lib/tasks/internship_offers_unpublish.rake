desc 'To be scheduled in cron at 6 am to update selected internship offers status to unpublished'
task internship_offers_unpublish: :environment do
  Rails.logger.info("----------------------------------------")
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), internship_offers_unpublish")
  Rails.logger.info("----------------------------------------")
  UnpublishFaultyOffersJob.new.perform
end