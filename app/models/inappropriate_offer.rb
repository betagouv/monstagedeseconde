class InappropriateOffer < ApplicationRecord
  include AdminInappropriateOfferable
  MIN_DETAILS_LENGTH = 10
  MAX_DETAILS_LENGTH = 350

  belongs_to :internship_offer
  belongs_to :user, optional: true
  belongs_to :moderator, class_name: 'User', optional: true

  validates :ground, :details, presence: true
  validates :details, length: { minimum: MIN_DETAILS_LENGTH, maximum: MAX_DETAILS_LENGTH }
  
  # Validations pour la modération
  validates :moderation_action, 
            inclusion: { in: %w[rejeter masquer supprimer] },
            allow_blank: true

  # Validation conditionnelle : si une action de modération est définie, un modérateur est obligatoire
  validates :moderator, presence: true, if: :moderation_action?

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

  def self.options_for_moderation_action
    {
      "rejeter" => "Rejeter le signalement",
      "masquer" => "Masquer temporairement l'offre",
      "supprimer" => "Supprimer définitivement l'offre"
    }
  end

  scope :anonymous_reports_count, ->(internship_offer_id: ) {
    where(internship_offer_id: internship_offer_id, user_id: nil).count
  }

  scope :user_reports_count, ->(user_id: ) {
    where(user_id: user_id).count
  }

  scope :moderated, -> { where.not(moderation_action: nil) }
  scope :pending_moderation, -> { where(moderation_action: nil) }

  def moderated?
    moderation_action.present?
  end

  def pending_moderation?
    !moderated?
  end

end
