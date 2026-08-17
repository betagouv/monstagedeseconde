require 'pretty_console'

namespace :sygne do
  desc 'Hebdo : compte les élèves éligibles SYGNE par classe, rafraîchit class_size + school_stats'
  task refresh_headcounts: :environment do
    PrettyConsole.announce_task 'Rafraîchissement des effectifs SYGNE pour tous les établissements' do
      School.find_each(batch_size: 50) do |school|
        CountStudentsFromSygneJob.perform_later(school)
        sleep 0.3
      end
    end
  end
end
