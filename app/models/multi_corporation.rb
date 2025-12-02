class MultiCorporation < ApplicationRecord
  belongs_to :multi_coordinator
  has_many :corporations, dependent: :destroy
end


