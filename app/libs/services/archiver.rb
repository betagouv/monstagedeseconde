module Services
  # Services::StudentArchiver.new(begins_at: Date.new(2019, 9, 1), ends_at: Date.new(2020, 8, 31))
  class Archiver
    # Set-based equivalents of Users::Student#anonymize / InternshipApplication#anonymize.
    # Only `email` is per-row: a random local part with the original domain preserved (or NULL when
    # blank), matching `"#{SecureRandom.hex}@#{email_domain_name}"`. `discarded_at` uses COALESCE so
    # an already-discarded student keeps its original timestamp (mirrors `discard! unless discarded?`).
    STUDENT_ANONYMIZATION_SQL = <<~SQL.squish.freeze
      first_name = 'NA',
      last_name = 'NA',
      phone = NULL,
      unconfirmed_email = NULL,
      current_sign_in_ip = NULL,
      last_sign_in_ip = NULL,
      anonymized = true,
      discarded_at = COALESCE(discarded_at, now()),
      birth_date = NULL,
      class_room_id = NULL,
      resume_other = NULL,
      resume_languages = NULL,
      gender = NULL,
      ine = NULL,
      address = NULL,
      legal_representative_full_name = NULL,
      legal_representative_phone = NULL,
      legal_representative_email = NULL,
      email = CASE
                WHEN email IS NULL OR email = '' THEN NULL
                ELSE md5(random()::text || id::text) || '@' || split_part(email, '@', 2)
              END
    SQL

    APPLICATION_ANONYMIZATION_SQL = <<~SQL.squish.freeze
      motivation = 'NA',
      student_address = 'NA',
      student_legal_representative_full_name = 'NA',
      student_legal_representative_email = 'NA',
      student_legal_representative_phone = '+330600110011',
      student_phone = '+330600110011',
      student_email = 'NA',
      rejected_message = NULL,
      canceled_by_employer_message = NULL,
      canceled_by_student_message = NULL,
      approved_message = NULL,
      restored_message = NULL
    SQL

    # Set-based anonymization: 2 UPDATEs per batch (applications, then students) instead of ~3
    # queries per student. `anonymized: true` marks a student done, so the query below skips
    # already-anonymized students and an interrupted run resumes instead of restarting.
    def self.archive_students(batch_size: Rails.env.production? ? 10_000 : 5_000)
      puts "🚀 Début de l'archivage des étudiants..."

      scope = Users::Student.kept.where(anonymized: false)
      total_students = scope.count
      puts "📊 Nombre total d'étudiants à archiver : #{total_students}"
      return if total_students.zero?

      archived_count = 0
      error_count = 0
      start_time = Time.current

      puts "⚡ Taille de batch : #{batch_size} (optimisé pour #{Rails.env})"

      scope.in_batches(of: batch_size).each_with_index do |batch, batch_index|
        ids = batch.pluck(:id)
        next if ids.empty?

        begin
          # One transaction per batch keeps each batch atomic while committing incrementally, so an
          # interrupted run resumes from the last committed batch. Applications are anonymized first:
          # a student is only flagged `anonymized: true` (and thus skipped next run) once its
          # applications' PII has been cleared in the same committed transaction.
          ActiveRecord::Base.transaction do
            InternshipApplication.where(user_id: ids).update_all(APPLICATION_ANONYMIZATION_SQL)
            Users::Student.where(id: ids).update_all(STUDENT_ANONYMIZATION_SQL)
          end
          archived_count += ids.size
        rescue StandardError => e
          error_count += ids.size
          puts "  ❌ Erreur sur le batch #{batch_index + 1} (ids #{ids.first}..#{ids.last}): #{e.message}"
          next
        end

        elapsed_time = Time.current - start_time
        rate = archived_count / elapsed_time if elapsed_time > 0
        estimated_remaining = (total_students - archived_count) / rate if rate && rate > 0
        progress = ((archived_count.to_f / total_students) * 100).round(1)

        puts "  ✅ #{archived_count}/#{total_students} étudiants archivés (#{progress}%) — " \
             "écoulé #{format_duration(elapsed_time)}" \
             "#{estimated_remaining ? ", restant ~#{format_duration(estimated_remaining)}" : ''}"
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

    # Physically deletes students that archive_students already anonymized, along with their
    # dependent rows. `User#destroy` anonymizes instead of deleting outside review apps and the FKs
    # to users have no ON DELETE CASCADE, so children are delete_all'ed in FK order first (same
    # order as RebuildReviewJob#remove_steps). Deleted students leave the scope by themselves, so
    # an interrupted run resumes where it stopped.
    def self.delete_anonymized_students(batch_size: 1_000)
      puts '🚀 Début de la suppression des étudiants anonymisés...'

      scope = Users::Student.where(anonymized: true)
      total_students = scope.count
      puts "📊 Nombre total d'étudiants à supprimer : #{total_students}"
      return if total_students.zero?

      deleted_count = 0
      error_count = 0
      start_time = Time.current

      puts "⚡ Taille de batch : #{batch_size}"

      scope.in_batches(of: batch_size).each_with_index do |batch, batch_index|
        ids = batch.pluck(:id)
        next if ids.empty?

        begin
          application_ids = InternshipApplication.where(user_id: ids).pluck(:id)
          agreement_ids = InternshipAgreement.where(internship_application_id: application_ids).pluck(:id)
          signature_ids = Signature.where(internship_agreement_id: agreement_ids).pluck(:id)

          # Handwritten signature images are PII: purge_later also deletes the S3 files. Enqueued
          # before the transaction — a purge job is harmless if the deletion below rolls back.
          ActiveStorage::Attachment.where(record_type: 'Signature', record_id: signature_ids)
                                   .find_each(&:purge_later)

          ActiveRecord::Base.transaction do
            Signature.where(id: signature_ids).delete_all
            CorporationInternshipAgreement.where(internship_agreement_id: agreement_ids).delete_all
            InternshipAgreement.where(id: agreement_ids).delete_all
            InternshipApplicationWeek.where(internship_application_id: application_ids).delete_all
            InternshipApplicationStateChange.where(internship_application_id: application_ids).delete_all
            InternshipApplication.where(id: application_ids).delete_all
            Favorite.where(user_id: ids).delete_all
            UrlShrinker.where(user_id: ids).delete_all
            UsersSearchHistory.where(user_id: ids).delete_all
            UsersInternshipOffersHistory.where(user_id: ids).delete_all
            BoardingHouseView.where(user_id: ids).delete_all
            # Keep the moderation history, only detach the deleted reporter
            InappropriateOffer.where(user_id: ids).update_all(user_id: nil)
            Users::Student.where(id: ids).delete_all
          end
          deleted_count += ids.size
        rescue StandardError => e
          error_count += ids.size
          puts "  ❌ Erreur sur le batch #{batch_index + 1} (ids #{ids.first}..#{ids.last}): #{e.message}"
          next
        end

        elapsed_time = Time.current - start_time
        rate = deleted_count / elapsed_time if elapsed_time > 0
        estimated_remaining = (total_students - deleted_count) / rate if rate && rate > 0
        progress = ((deleted_count.to_f / total_students) * 100).round(1)

        puts "  ✅ #{deleted_count}/#{total_students} étudiants supprimés (#{progress}%) — " \
             "écoulé #{format_duration(elapsed_time)}" \
             "#{estimated_remaining ? ", restant ~#{format_duration(estimated_remaining)}" : ''}"
      end

      total_time = Time.current - start_time
      puts '🎉 Suppression terminée !'
      puts '📊 Résumé:'
      puts "  ✅ Étudiants supprimés: #{deleted_count}"
      puts "  ❌ Erreurs: #{error_count}"
      puts "  ⏱️  Temps total: #{format_duration(total_time)}"
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
