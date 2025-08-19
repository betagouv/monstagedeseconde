class ReservedSchool < ApplicationRecord
  belongs_to :school
  belongs_to :internship_offer
end
