class InappropriateOffer < ApplicationRecord
  MIN_DETAILS_LENGTH = 10
  MAX_DETAILS_LENGTH = 350

  belongs_to :internship_offer
  belongs_to :user, optional: true

  validates :ground, :details, presence: true
  validates :details, length: { minimum: MIN_DETAILS_LENGTH, maximum: MAX_DETAILS_LENGTH }

  def self.options_for_ground
    {
      "suspicious_content" => "Contenu suspect",
      "inappropriate_content" => "Contenu inapproprié",
      "incorrect_address" => "Adresse incorrecte",
      "false_or_misleading_information" => "Informations fausses ou trompeuses",
      "other" => "Autre"
    }
  end

  def self.options_for_select
    options_for_ground.map { |label, value| [value, label] }
  end

  scope :anonymous_reports_count, ->(internship_offer_id: ) {
    where(internship_offer_id: internship_offer_id, user_id: nil).count
  }

  scope :user_reports_count, ->(user_id: ) {
    where(user_id: user_id).count
  }

end
