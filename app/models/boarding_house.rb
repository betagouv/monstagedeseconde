# frozen_string_literal: true

class BoardingHouse < ApplicationRecord
  include Nearbyable

  belongs_to :academy

  before_validation :set_department_from_zipcode

  validates :name, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :department, presence: true
  validates :available_places, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true
  validate :department_belongs_to_academy

  # Override Nearbyable's coordinates validation — coordinates are optional
  # (geocoded automatically, may fail)
  def coordinates_are_valid?
    true
  end

  private

  def set_department_from_zipcode
    return if zipcode.blank?

    dept = Department.fetch_by_zipcode(zipcode: zipcode)
    self.department = dept.name if dept
  end

  def department_belongs_to_academy
    return if zipcode.blank? || academy.blank?

    dept = Department.fetch_by_zipcode(zipcode: zipcode)
    return if dept.nil?

    unless academy.departments.include?(dept)
      errors.add(:zipcode, :not_in_academy, message: "ne correspond pas à un département de l'académie de #{academy.name}")
    end
  end
end
