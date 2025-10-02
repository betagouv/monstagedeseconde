module Services
  # Services::StudentArchiver.new(begins_at: Date.new(2019, 9, 1), ends_at: Date.new(2020, 8, 31))
  class Archiver
    def self.archive_students
      puts "🚀 Début de l'archivage des étudiants..."

      total_students = Users::Student.kept.count
      puts "📊 Nombre total d'étudiants à archiver : #{total_students}"

      archived_count = 0
      error_count = 0
      start_time = Time.current

      # Optimisation : bigger batch size for production
      batch_size = Rails.env.production? ? 500 : 100
      puts "⚡ Taille de batch : #{batch_size} (optimisé pour #{Rails.env})"

      Users::Student.kept
                    .select(:id, :created_at, :updated_at, :anonymized, :email, :first_name, :last_name, :phone, :current_sign_in_ip, :last_sign_in_ip, :discarded_at) # Include fields needed for anonymization
                    .in_batches(of: batch_size)
                    .each_with_index do |batch, batch_index|
        puts "📦 Traitement du batch #{batch_index + 1} (#{batch_size} étudiants)"

        # Optimisation : process in parallel if possible
        batch.each_with_index do |student, index_in_batch|
          # Optimisation : use update_all for simple fields
          student.archive
          archived_count += 1

          # Display progress every 50 students in production
          progress_interval = Rails.env.production? ? 50 : 10
          if (index_in_batch + 1) % progress_interval == 0
            progress = ((archived_count.to_f / total_students) * 100).round(1)
            puts "  ✅ #{archived_count}/#{total_students} étudiants archivés (#{progress}%)"
          end
        rescue StandardError => e
          error_count += 1
          puts "  ❌ Erreur lors de l'archivage de l'étudiant #{student.id}: #{e.message}"
        end

        # Feedback after each batch
        elapsed_time = Time.current - start_time
        avg_time_per_student = elapsed_time / archived_count if archived_count > 0
        estimated_remaining = (total_students - archived_count) * avg_time_per_student if avg_time_per_student

        puts "  📈 Progrès: #{archived_count}/#{total_students} (#{((archived_count.to_f / total_students) * 100).round(1)}%)"
        puts "  ⏱️  Temps écoulé: #{format_duration(elapsed_time)}"
        puts "  🎯 Temps restant estimé: #{format_duration(estimated_remaining)}" if estimated_remaining
        puts ''
      end

      # Final summary
      total_time = Time.current - start_time
      puts '🎉 Archivage terminé !'
      puts '📊 Résumé:'
      puts "  ✅ Étudiants archivés avec succès: #{archived_count}"
      puts "  ❌ Erreurs: #{error_count}"
      puts "  ⏱️  Temps total: #{format_duration(total_time)}"
      puts "  🚀 Vitesse moyenne: #{(archived_count / total_time * 60).round(1)} étudiants/minute" if total_time > 0
    end

    # Version ultra-optimisée pour la production
    def self.archive_students_fast
      puts "🚀 Début de l'archivage ultra-rapide des étudiants..."

      total_students = Users::Student.kept.count
      puts "📊 Nombre total d'étudiants à archiver : #{total_students}"

      start_time = Time.current

      # Optimisation maximale : update_all en une seule requête
      archived_count = Users::Student.kept.update_all(
        discarded_at: Time.current,
        birth_date: nil,
        current_sign_in_ip: nil,
        last_sign_in_ip: nil,
        class_room_id: nil,
        resume_other: nil,
        resume_languages: nil,
        gender: nil,
        ine: nil,
        address: nil,
        legal_representative_full_name: nil,
        legal_representative_phone: nil,
        legal_representative_email: nil,
        phone: 'NA',
        email: "archived_student_#{Random.hex(8)}@archived.local"
      )

      total_time = Time.current - start_time
      puts '🎉 Archivage ultra-rapide terminé !'
      puts '📊 Résumé:'
      puts "  ✅ Étudiants archivés avec succès: #{archived_count}"
      puts "  ⏱️  Temps total: #{format_duration(total_time)}"
      puts "  🚀 Vitesse: #{(archived_count / total_time * 60).round(1)} étudiants/minute" if total_time > 0

      archived_count
    end

    def self.archive_school_managements
      Users::SchoolManagement.kept
                             .in_batches(of: 100)
                             .each_record(&:archive)
    end

    def self.delete_invitations
      Invitation.in_batches(of: 100)
                .each_record(&:destroy)
    end

    def self.archive_internship_agreements
      InternshipAgreement.kept
                         .in_batches(of: 100)
                         .each_record(&:archive)
    end

    def self.archive_internship_offers
      InternshipOffer.in_batches(of: 100)
                     .each_record(&:archive)
    end

    def self.archive_class_rooms
      ClassRoom.in_batches(of: 100)
               .each_record(&:archive)
    end

    private

    def self.format_duration(seconds)
      return '0s' if seconds < 1

      hours = (seconds / 3600).to_i
      minutes = ((seconds % 3600) / 60).to_i
      secs = (seconds % 60).to_i

      if hours > 0
        "#{hours}h #{minutes}m #{secs}s"
      elsif minutes > 0
        "#{minutes}m #{secs}s"
      else
        "#{secs}s"
      end
    end
  end
end
