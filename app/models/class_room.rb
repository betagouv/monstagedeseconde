# frozen_string_literal: true

class ClassRoom < ApplicationRecord
  belongs_to :school
  belongs_to :grade, optional: true
  has_many :students, class_name: 'Users::Student',
                      dependent: :nullify
  has_many :school_managements, class_name: 'Users::SchoolManagement',
                                dependent: :nullify do

    def teachers
      where(role: :teacher)
    end
  end

  def teacher
    school_managements&.teachers&.first
  end

  def to_s
    name
  end

  def archive
    update_columns(
      name: 'NA',
      school_id: nil
    )
  end
end
