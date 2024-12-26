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
  has_many :plannings, through: :planning_grades
  has_many :planning_grades, dependent: :destroy
  has_many :internship_offer_grades, dependent: :destroy
  has_many :internship_offers, through: :internship_offer_grades
  has_many :identities

  def troisieme_or_quatrieme?
    short_name.in?(%w[troisieme quatrieme])
  end
  alias troisieme_ou_quatrieme? troisieme_or_quatrieme?

  def seconde?
    short_name == 'seconde'
  end

  def troisieme_or_quatrieme?
    short_name.in?(%w[troisieme quatrieme])
  end

  def self.troisieme
    fetch_by_short_name('troisieme').first
  end

  def self.quatrieme
    fetch_by_short_name('quatrieme').first
  end

  def self.troisieme_et_quatrieme
    fetch_by_short_name(%w[troisieme quatrieme])
  end

  def self.seconde
    fetch_by_short_name('seconde').first
  end

  def self.options_for_select(current_user)
    complete_list = all.map { |grade| [grade.name, grade.id] }
    return complete_list if current_user.nil? || !current_user.student?

    complete_list.filter { |grade| grade[1] == current_user.grade_id }
  end

  def school_track
    return SchoolTrack::Troisieme if short_name.in?(%w[troisieme quatrieme])

    SchoolTrack::Seconde
  end

  def self.fetch_by_short_name(short_names)
    Grade.where(short_name: short_names)
  end
end
