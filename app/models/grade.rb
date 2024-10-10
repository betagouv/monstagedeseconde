class Grade < ApplicationRecord
  # frozen_string_literal: true

  # Attributes
  # id: integer, not null, primary key
  # name: string, not null
  # short_name: string, not null
  # school_year_end_month: string, not null
  # school_year_end_day: string, not null
  # created_at: datetime, not null
  # updated_at: datetime, not null

  # Relationships
  # has_many :internship_offers, through: :internship_offer_grades
  has_many :plannings, through: :planning_grades
  has_many :planning_grades, dependent: :destroy

  def self.troisieme
    fetch_by_short_name('troisieme')
  end

  def self.quatrieme
    fetch_by_short_name('quatrieme')
  end

  def self.troisieme_et_quatrieme
    fetch_by_short_name(%w[troisieme quatrieme])
  end

  def self.seconde
    fetch_by_short_name('seconde')
  end

  def school_track
    return SchoolTrack::Troisieme if short_name.in?(%w(troisieme quatrieme))

    SchoolTrack::Seconde
  end

  private

  def self.fetch_by_short_name(short_names_array)
    Grade.where(short_name: short_names_array)
  end
end
