require 'pretty_console'

namespace :update_internship_offers do
  desc 'Copy internship_occupation.address to internship_offer.address'
  task :update_addresses => :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"
    # 
    InternshipOffer.kept.find_in_batches do |batch|
      sleep(3)
      batch.each do |offer|
        next if offer.internship_occupation.blank?
        offer.update(street: offer.internship_occupation.street)
        offer.update(zipcode: offer.internship_occupation.zipcode)
        offer.update(city: offer.internship_occupation.city)
        offer.update(coordinates: offer.internship_occupation.coordinates)
        print '.'
      end
    end
    puts ''
    PrettyConsole.say_in_green 'Task completed'
  end
end


