# frozen_string_literal: true

module TroisiemeDuplicationPeriod
  extend ActiveSupport::Concern

  # Duplication d'offres 3ème interdite : du lundi de la semaine ISO contenant le 31 mai
  # jusqu'au 1er juillet inclus.
  def troisieme_duplication_forbidden?
    today = Date.current
    today.between?(troisieme_duplication_forbidden_start, Date.new(today.year, 7, 1))
  end

  def troisieme_duplication_forbidden_start
    Date.new(Date.current.year, 5, 31).beginning_of_week(:monday)
  end

  def troisieme_duplication_forbidden_message
    start_date = troisieme_duplication_forbidden_start
    "La duplication d'offres pour les collégiens n'est pas possible entre le " \
    "#{I18n.l(start_date, format: '%-d %B')} et le 1er juillet."
  end
end
