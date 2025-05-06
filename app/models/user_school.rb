# frozen_string_literal: true

class UserSchool < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  belongs_to :school

  validates :user_id, uniqueness: { scope: :school_id }
end
