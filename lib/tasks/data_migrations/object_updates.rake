require 'pretty_console'
namespace :data_migrations do

  desc 'create "lycees" from csv file'
  task 'add_info_to_schools': :environment do
    import 'csv'
    col_hash= { uai: 0, public_private: 1,  contract_label: 2, contract_code: 3}
    error_lines = []
    file_location = Rails.root.join('db/data_imports/school_public_prive.csv')
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';')

      uai = cells[col_hash[:uai]]
      next if uai.nil?
      school = School.find_by(code_uai: uai)
      next if school.nil?

      is_public = cells[col_hash[:public_private]].gsub("\n", '') == "Public"
      contract_code = cells[col_hash[:contract_code]].gsub("\n", '')
      contract_label = cells[col_hash[:contract_label]].gsub("\n", '')

      school_params = {
        is_public: is_public,
        contract_code: contract_code,
        contract_label: contract_label
      }

      result = school.update(**school_params)
      if result
        print "."
      else
        error_lines << ["Ligne #{line_nr}" , school.name, school.errors.full_messages.join(", ")]
        print "o"
      end
    end
    puts ""
    PrettyConsole.say_in_yellow  "Done with updating schools(lycées)"
  end
end