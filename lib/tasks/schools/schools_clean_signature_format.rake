namespace :schools do
  desc "Convertit toutes les signatures d'écoles en PNG non entrelacé"
  task desinterlace_signatures: :environment do
    School.joins(:signature_attachment).find_each do |school|
      puts "Processing school #{school.id}"
      DesinterlaceSchoolSignatureJob.perform_later(school.id)
    end
    puts "Jobs de désentrelacement lancés pour toutes les signatures d'écoles."
  end

  desc "school type verification with collège agricole featuring"
  task :verify_college_agricole, [:file_name] => :environment do |task, args|
    # invoke as : rake "schools:verify_college_agricole[<file_name>]"
    PrettyConsole.announce_task 'Importing students from schools with no students' do
      file_name = args.file_name || 'liste_etablissements_complete.csv'
      raise 'Please provide a file name' if file_name.nil?
      counter_found = 0
      wrong_type_count = 0
      lycee_agricole_count = 0
      lycee_agricole_not_labelled_as_lycee_count = 0
      file_name = Rails.root.join('db','data_imports','sources_EN', file_name)
      CSV.foreach(file_name, headers: true) do |row|
        # puts "#{row['Identifiant_de_l_etablissement']} - #{row['Type_etablissement']} - #{row['Lycee_Agricole']}"
        next if row['Identifiant_de_l_etablissement'].nil?
        school = School.find_by(code_uai: row['Identifiant_de_l_etablissement'])
        next if school.nil?
        # school = School.find_by(code_uai: row['Identifiant_de_l_etablissement'])
        counter_found += 1

        file_school_type = row['Type_etablissement'].strip.downcase.gsub(/[éè]/, 'e') # Lycée or Collège
        file_lycee_agricole = row['Lycee_Agricole'].to_i # "1" or "0"

        if school.school_type != file_school_type
          wrong_type_count += 1
          if file_school_type.in?(['college', 'lycee'])
            school.update(school_type: file_school_type)
            puts "  - mise à jour #{file_school_type}"
          end
        end

        if school.school_type == 'lycee' && file_lycee_agricole != 1
          lycee_agricole_count += 1
        end
        if school.school_type != 'lycee' && file_lycee_agricole != 1
          lycee_agricole_not_labelled_as_lycee_count += 1
        end
      end
      PrettyConsole.say_in_cyan("found: ##{counter_found}")
      PrettyConsole.say_in_red("wrong type: ##{wrong_type_count}")
      PrettyConsole.say_in_red("lycée agricole: ##{lycee_agricole_count}")
      PrettyConsole.say_in_red("lycée agricole not labelled as lycée: ##{lycee_agricole_not_labelled_as_lycee_count}")
    end
  end
end
