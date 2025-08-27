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

      Users::Student.kept
                    .in_batches(of: 100)
                    .each_with_index do |batch, batch_index|
        puts "📦 Traitement du batch #{batch_index + 1} (#{batch.count} étudiants)"

        batch.each_with_index do |student, index_in_batch|
          begin
            student.archive
            archived_count += 1

            # Display progress every 10 students
            if (index_in_batch + 1) % 10 == 0
              progress = ((archived_count.to_f / total_students) * 100).round(1)
              puts "  ✅ #{archived_count}/#{total_students} étudiants archivés (#{progress}%)"
            end
          rescue => e
            error_count += 1
            puts "  ❌ Erreur lors de l'archivage de l'étudiant #{student.id}: #{e.message}"
          end
        end

        # Feedback after each batch
        elapsed_time = Time.current - start_time
        avg_time_per_student = elapsed_time / archived_count if archived_count > 0
        estimated_remaining = (total_students - archived_count) * avg_time_per_student if avg_time_per_student

        puts "  📈 Progrès: #{archived_count}/#{total_students} (#{((archived_count.to_f / total_students) * 100).round(1)}%)"
        puts "  ⏱️  Temps écoulé: #{format_duration(elapsed_time)}"
        if estimated_remaining
          puts "  🎯 Temps restant estimé: #{format_duration(estimated_remaining)}"
        end
        puts ""
      end

      # Final summary
      total_time = Time.current - start_time
      puts "🎉 Archivage terminé !"
      puts "📊 Résumé:"
      puts "  ✅ Étudiants archivés avec succès: #{archived_count}"
      puts "  ❌ Erreurs: #{error_count}"
      puts "  ⏱️  Temps total: #{format_duration(total_time)}"
      puts "  🚀 Vitesse moyenne: #{(archived_count / total_time * 60).round(1)} étudiants/minute" if total_time > 0
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

    def self.archive_identities
      Identity.in_batches(of: 100)
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
      return "0s" if seconds < 1

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
