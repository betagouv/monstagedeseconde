# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :internship_offers
  before_create :set_uuid

  MAPPING_COVER = {
    "Agriculture" => "agriculture.svg",
    "Agroéquipement" => "agriculture.svg",
    "Architecture, urbanisme et paysage" => "architecture.svg",
    "Armée - Défense" => "armee.svg",
    "Art et design" => "art_design.svg",
    "Artisanat d'art" => "artisanat.svg",
    "Arts du spectacle" => "arts_spectacle.svg",
    "Audiovisuel" => "audiovisuel.svg",
    "Automobile" => "automobile.svg",
    "Banque et assurance" => "banque.svg",
    "Bâtiment et travaux publics (BTP)" => "btp.svg",
    "Bien-être" => "paramedical.svg",
    "Commerce et distribution" => "commerce.svg",
    "Communication" => "communication.svg",
    "Comptabilité, gestion, ressources humaines" => "gestion.svg",
    "Conseil et audit" => "banque.svg",
    "Construction aéronautique, ferroviaire et navale" => "industrie.svg",
    "Culture et patrimoine" => "culture.svg",
    "Droit et justice" => "droit.svg",
    "Édition, librairie, bibliothèque" => "edition.svg",
    "Électronique" => "electronique.svg",
    "Énergie" => "energie.svg",
    "Enseignement" => "enseignement.svg",
    "Environnement" => "environnement.svg",
    "Filiere bois" => "filiere_bois.svg",
    "Fonction publique" => "administration.svg",
    "Hôtellerie, restauration" => "hotellerie_restauration.svg",
    "Immobilier, transactions immobilières" => "immobilier.svg",
    "Industrie alimentaire" => "industrie_alimentaire.svg",
    "Industrie chimique" => "industrie.svg",
    "Industrie, ingénierie industrielle" => "industrie.svg",
    "Informatique et réseaux" => "informatique.svg",
    "Jeu vidéo" => "informatique.svg",
    "Journalisme" => "marketing.svg",
    "Logistique et transport" => "automobile.svg",
    "Maintenance" => "industrie.svg",
    "Marketing, publicité" => "marketing.svg",
    "Mécanique" => "mecanique.svg",
    "Métiers d'art" => "art_design.svg",
    "Mode" => "mode.svg",
    "Papiers Cartons" => "filiere_bois.svg",
    "Paramédical" => "paramedical.svg",
    "Recherche" => "industrie_alimentaire.svg",
    "Santé" => "paramedical.svg",
    "Sécurité" => "securite.svg",
    "Services postaux" => "postal.svg",
    "Social" => "social.svg",
    "Sport" => "sport.svg",
    "Tourisme" => "tourisme.svg",
    "Traduction, interprétation" => "gestion.svg",
    "Verre, béton, céramique" => "industrie.svg"
  }

  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :name
      field :uuid
    end
    show do
      field :name
      field :uuid
    end
    edit do
      field :name
    end
  end

  def cover
    MAPPING_COVER[name] || 'default_sector.svg'
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid if self.uuid.blank?
  end
end
