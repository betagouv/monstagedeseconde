# frozen_string_literal: true

class InternshipOfferGrade < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :grade
end
