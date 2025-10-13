require 'pretty_console'

namespace :schools do
  # usage : rake "schools:applications_in_schools[0752694W;012584X; ...]"
  desc 'counts how many approved applications per designated school'
  task :applications_in_schools, [:codes_uai] => :environment do |task, args|
    puts(args.codes_uai)
    args_separator = ';'
    codes_uai = args.codes_uai.split(args_separator).map(&:strip)
    codes_uai.each do |code_uai|
      school = School.find_by(code_uai: code_uai)
      school_year_start = SchoolYear::Current.new.offers_beginning_of_period
      school_year_end = SchoolYear::Current.new.deposit_end_of_period

      if school.nil?
        PrettyConsole.puts_in_red("aucune école n'a ce code : #{code_uai}")
      else
        applications = InternshipApplication.joins(student: :school)
                                            .where(school: { code_uai: code_uai })
                                            .where(aasm_state: :approved)
                                            .where('internship_applications.updated_at >= ?', school_year_start)
                                            .where('internship_applications.updated_at <= ?', school_year_end)

        message = "Le nombre de stages conclus dans l'établissement #{school.name}" \
                  " (#{code_uai}) est à ce jour de #{applications.count}"
        PrettyConsole.say_in_green message
      end
    end
  end

  desc 'what are the new schools in the current school year'
  task new_schools_in_current_school_year: :environment do |task, args|
    school_year_start = SchoolYear::Current.new.offers_beginning_of_period
    school_year_end = SchoolYear::Current.new.deposit_end_of_period
    new_schools = School.where('created_at >= ?', school_year_start)
                        .where('created_at <= ?', school_year_end)
                        .order(:created_at)
                        .pluck(:code_uai, :name, :city, :department, :created_at)
                        .map do |sco|
      sco[4] = sco[4].strftime('%d/%m/%Y')
      sco.join(',')
    end.join('')
    PrettyConsole.say_in_green "Le nombre d'établissements créés dans l'année scolaire courante est de #{new_schools.count}"
  end

  desc 'analyze_class_rooms'
  task :analyze_class_rooms, [:limit] => :environment do |task, args|
    limit = args.limit.to_i || 100
    total_students = 0
    total_class_rooms = class_rooms.count
    class_rooms_without_students = 0
    counter = 0
    ClassRoom.find_each do |class_room|
      counter += 1
      break if counter > limit
      if class_room.students.empty?
        class_rooms_without_students += 1
        PrettyConsole.puts_in_red("La classe #{class_room.name} (#{class_room.id}) n'a pas d'élève , école: #{class_room.school.name} #{class_room.school.code_uai}")
      end
      total_students += class_room.students.count
    end
    average_students_per_class_room = if total_class_rooms.positive?
                                        total_students.to_f / total_class_rooms
                                      else
                                        0
                                      end
    PrettyConsole.say_in_green "Le nombre total de classes est de #{total_class_rooms}"
    PrettyConsole.say_in_green "Le nombre total d'élèves est de #{total_students}"
    PrettyConsole.say_in_green "Le nombre de classes sans élèves est de #{class_rooms_without_students}"
    PrettyConsole.say_in_green "Le nombre moyen d'élèves par classe est de #{average_students_per_class_room.round(2)}"
  end
end
