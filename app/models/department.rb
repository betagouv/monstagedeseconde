class Department < ApplicationRecord
  # frozen_string_literal: true

  # Attributes
  # id: integer, not null, primary key
  # name: string, not null
  # code: string, not null
  # created_at: datetime, not null
  # updated_at: datetime, not null

  # Relationships
  has_many :departments_operators
  has_many :operators, through: :departments_operators

  def self.lookup_by_zipcode(zipcode:)
    Department.find_by(code: key_for_lookup(zipcode: zipcode)).try(:name)
  end

  def self.key_for_lookup(zipcode:)
    if corsica?(zipcode: zipcode)
      CorsicaZipcode.find_by(zipcode: zipcode).try(:department_code) || '2A'
    elsif departement_identified_by_3_chars?(zipcode: zipcode)
      zipcode[0..2]
    else
      zipcode[0..1]
    end
  end

  def self.to_select(only: nil)
    list = if only
              Department.find_by code: only
            else
              Department.all.map
            end
    list.map { |code, name| ["#{code} - #{name}", name.to_s] }
        .uniq { |item| item[1] }
        .sort
  end

  def self.corsica?(zipcode:)
    zipcode.starts_with?('20')
  end

  # edge case for [971->978]
  def self.departement_identified_by_3_chars?(zipcode:)
    zipcode.starts_with?('97') ||
    zipcode.starts_with?('98')
  end
end
