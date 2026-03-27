# frozen_string_literal: true

class NafSectorMapping < ApplicationRecord
  belongs_to :sector

  validates :code_naf, presence: true
  validates :date_start, presence: true
  validates :date_end, presence: true
  validate :date_end_after_date_start

  scope :active_at, ->(date) { where('date_start <= ? AND date_end >= ?', date, date) }

  rails_admin do
    weight 16
    navigation_label 'Divers'
    label 'Correspondance code NAF / secteur'
    label_plural 'Correspondances code NAF / secteur'

    list do
      field :code_naf
      field :sector
      field :date_start
      field :date_end
    end
    show do
      field :code_naf
      field :sector
      field :date_start
      field :date_end
    end
    edit do
      field :code_naf
      field :sector
      field :date_start
      field :date_end
    end
  end

  def self.find_sector_by_code_naf(code_naf, date: Date.today)
    return nil if code_naf.blank?

    # Extract the NAF division (first 2 digits before the dot), e.g. "81.10Z" -> "81"
    naf_prefix = code_naf.split('.').first

    mapping = active_at(date).find_by(code_naf: code_naf)
    mapping ||= active_at(date).find_by(code_naf: naf_prefix)

    mapping&.sector
  end

  private

  def date_end_after_date_start
    return if date_start.blank? || date_end.blank?

    errors.add(:date_end, 'doit être postérieure à la date de début') if date_end < date_start
  end
end
