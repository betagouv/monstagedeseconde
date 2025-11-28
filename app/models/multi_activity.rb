# frozen_string_literal: true

class MultiActivity < ApplicationRecord
  TITLE_MAX_LENGTH = 120
  DESCRIPTION_MAX_LENGTH = 1500

  belongs_to :employer, class_name: 'User'

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
  validates :description, presence: true, length: { maximum: DESCRIPTION_MAX_LENGTH }

  def is_fully_editable?
    true
  end
end

