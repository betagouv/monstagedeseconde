# frozen_string_literal: true

class School < ApplicationRecord
  include Nearbyable
  include Zipcodable
  include SchoolUsersAssociations

  has_many :class_rooms, dependent: :destroy
  has_many :internship_offers, dependent: :nullify
  has_many :internship_applications, through: :students
  has_many :internship_agreements, through: :internship_applications
  has_many :dedicated_internship_offers, foreign_key: :school_id, dependent: :nullify, class_name: 'InternshipOffer'
  belongs_to :department, optional: true

  has_rich_text :agreement_conditions_rich_text

  validates :city, :name, :code_uai, presence: true
  validates :code_uai, uniqueness: { message: 'Ce code UAI est déjà utilisé, le lycée est déjà enregistré' }
  validates :zipcode, zipcode: { country_code: :fr }

  before_save :set_legal_status

  CONTRACT_CODES = {
    '10' => 'HORS CONTRAT',
    '30' => "CONTRAT D'ASSOCIATION TOUTES CLASSES",
    '31' => 'CONTRAT ASSOCIATION PARTIE DES CLASSES',
    '99' => 'SANS OBJET'
  }
  VALID_TYPE_PARAMS = %w[rep rep_plus qpv qpv_proche].freeze

  scope :with_manager, lambda {
                         left_joins(:school_manager)
                           .group('schools.id')
                           .having('count(users.id) > 0')
                       }
  scope :without_manager, lambda {
    left_joins(:school_manager).group('schools.id')
                               .having('count(users.id) = 0')
  }

  scope :with_school_manager, lambda {
    School.where(id: Users::SchoolManagement.kept
                                            .where(role: 'school_manager')
                                            .pluck(:school_id))
  }

  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def agreement_address
    "Lycée #{name} - #{city}, #{zipcode}"
  end

  def presenter
    Presenters::School.new(self)
  end

  def default_search_options
    {
      city:,
      latitude: coordinates.lat,
      longitude: coordinates.lon,
      radius: Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER
    }
  end

  def has_staff?
    users.where("role = 'teacher' or role = 'main_teacher' or role = 'other'")
         .count
         .positive?
  end

  def to_s
    name
  end

  def email_domain_name
    department.academy.email_domain
  end

  private

  def contract_label
    return 'Public' if is_public?
    return 'Privé sous contrat' if contract_code.in?(%w[30 31])

    'Privé hors contrat'
  end

  def contract_code_label
    CONTRACT_CODES[contract_code]
  end

  def set_legal_status
    self.legal_status = contract_label
  end
end
