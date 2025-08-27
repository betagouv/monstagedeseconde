class StudentsAnonymizeJob < ActiveJob::Base
  queue_as :default

  def perform
    Rails.logger.info "🚀 Début du job d'archivage des étudiants"
    Rails.logger.info "⏰ Job démarré à #{Time.current}"
    
    begin
      Services::Archiver.archive_students
      Rails.logger.info "✅ Job d'archivage terminé avec succès"
    rescue => e
      Rails.logger.error "❌ Erreur dans le job d'archivage: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
    
    Rails.logger.info "⏰ Job terminé à #{Time.current}"
  end
end