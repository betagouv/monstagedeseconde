require 'pretty_console'
require 'csv'

namespace :data_migrations do
  desc 'school data import'
  task import_school_data: :environment do |task|
    PrettyConsole.announce_task 'create school data file' do
      file = 'db/data_imports/school_data_ms3e.csv'
      # csv opening from line 2 to avoid the header
      CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
        department = Department.fetch_by_zipcode(zipcode: row[:zipcode])
        school = School.new(
          name: row[:name],
          city: row[:city],
          zipcode: row[:zipcode],
          code_uai: row[:code_uai],
          coordinates: row[:coordinates],
          street: row[:street],
          created_at: row[:created_at],
          updated_at: row[:updated_at],
          city_tsv: row[:city_tsv],
          kind: row[:kind],
          visible: row[:visible],
          internship_agreement_online: row[:internship_agreement_online],
          fetched_school_phone: row[:fetched_school_phone],
          school_type: :college
        )
        school.department = department
        school.save!
      end
    end
  end
end
