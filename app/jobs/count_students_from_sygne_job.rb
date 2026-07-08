class CountStudentsFromSygneJob < ActiveJob::Base
  queue_as :data_import

  # Les erreurs SYGNE par établissement sont déjà capturées dans le service
  # (log + statistique écrite avec effectif nil), afin qu'un établissement en
  # erreur n'interrompe pas le run hebdomadaire complet.
  def perform(school)
    Services::Omogen::SchoolHeadcountRefresher.new(school).call
  end
end
