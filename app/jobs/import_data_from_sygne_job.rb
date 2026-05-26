class ImportDataFromSygneJob < ActiveJob::Base
  queue_as :data_import

  retry_on Services::Omogen::SygneApiError, wait: :polynomially_longer, attempts: 2

  def perform(school)
    omogen = Services::Omogen::Sygne.new
    omogen.sygne_import_by_schools(school.code_uai)
    school.update(full_imported: true)
  end
end
