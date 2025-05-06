# frozen_string_literal: true

namespace :school_management do
  desc 'Migre les SchoolManagement existants vers le nouveau système de jointure'
  task migrate_to_user_schools: :environment do
    puts 'Début de la migration des SchoolManagement...'

    # Récupérer tous les SchoolManagement qui ont une école
    school_managements = Users::SchoolManagement.joins(:school).distinct

    total = school_managements.count
    puts "Nombre d'utilisateurs à migrer : #{total}"

    migrated = 0
    errors = 0

    school_managements.find_each do |user|
      # Créer l'association dans user_schools si elle n'existe pas
      unless UserSchool.exists?(user: user, school: user.school)
        UserSchool.create!(user: user, school: user.school)
        puts "Création de l'association pour #{user.email} avec #{user.school.name}"
      end

      # Si l'utilisateur est un school_manager, créer les associations pour les autres établissements
      if user.school_manager? && user.school.uai_codes.present?
        user.school.uai_codes.each do |uai_code|
          next if uai_code == user.school.uai_code # Skip l'établissement actuel

          other_school = School.find_by(uai_code: uai_code)
          next unless other_school

          unless UserSchool.exists?(user: user, school: other_school)
            UserSchool.create!(user: user, school: other_school)
            puts "Création de l'association pour #{user.email} avec #{other_school.name}"
          end
        end
      end

      migrated += 1
      puts "Progression : #{migrated}/#{total}" if (migrated % 100).zero?
    rescue StandardError => e
      errors += 1
      puts "Erreur pour #{user.email} : #{e.message}"
    end

    puts "\nMigration terminée !"
    puts "Utilisateurs migrés avec succès : #{migrated}"
    puts "Erreurs rencontrées : #{errors}"
  end
end
