class StudentsAnonymizeJob < ActiveJob::Base
  queue_as :default

  def perform(use_fast_method = false)
    Rails.logger.info "🚀 Début du job d'archivage des étudiants"
    Rails.logger.info "⏰ Job démarré à #{Time.current}"
    Rails.logger.info "⚡ Mode rapide: #{use_fast_method}"

    begin
      if use_fast_method
        Rails.logger.info '🚀 Utilisation de la méthode ultra-rapide'
        Services::Archiver.archive_students_fast
      else
        Rails.logger.info '🚀 Utilisation de la méthode standard'
        Services::Archiver.archive_students
      end
      Rails.logger.info "✅ Job d'archivage terminé avec succès"
    rescue StandardError => e
      Rails.logger.error "❌ Erreur dans le job d'archivage: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end

    Rails.logger.info "⏰ Job terminé à #{Time.current}"
  end
end
