class ImportDataFromSygneJob < ActiveJob::Base
  queue_as :data_import

  def perform(school)
    omogen = Services::Omogen::Sygne.new
    omogen.sygne_import_by_schools(school.code_uai)
  end
end
