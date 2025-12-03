class MultiCorporation < ApplicationRecord
  belongs_to :multi_coordinator
  has_many :corporations, dependent: :destroy
  has_one :internship_offer, foreign_key: :multi_corporation_id
  
end


