class BoardingHouseView < ApplicationRecord
  belongs_to :boarding_house
  belongs_to :user, optional: true
end
