namespace :boarding_houses do
  desc 'Géocode les internats dont les coordonnées sont NULL (via BAN puis Nominatim en fallback)'
  task backfill_coordinates: :environment do
    scope = BoardingHouse.where(coordinates: nil)
    total = scope.count
    puts "#{total} internat(s) à géocoder..."

    success = 0
    failed = []

    scope.find_each.with_index do |bh, i|
      status = if bh.save
                 success += 1
                 'OK'
               else
                 failed << { id: bh.id, name: bh.name, address: bh.full_address, errors: bh.errors.full_messages }
                 'ÉCHEC'
               end
      puts "  [#{i + 1}/#{total}] #{bh.name} — #{status}"
    end

    puts "\nRésultat : #{success}/#{total} géocodés avec succès"
    return if failed.empty?

    puts "\nÉchecs (#{failed.size}) :"
    failed.each do |f|
      puts "  - ##{f[:id]} #{f[:name]} (#{f[:address]})"
      f[:errors].each { |e| puts "      · #{e}" }
    end
  end
end
