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

  has_rich_text :agreement_conditions_rich_text

  validates :city, :name, :code_uai, presence: true
  validates :code_uai, uniqueness: true
  validates :zipcode, zipcode: { country_code: :fr }

  before_save :set_legal_status

  CONTRACT_CODES = {
    "10" => "HORS CONTRAT",
    "30" => "CONTRAT D'ASSOCIATION TOUTES CLASSES",
    "31" => "CONTRAT ASSOCIATION PARTIE DES CLASSES",
    "99" => "SANS OBJET"
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

  scope :with_school_manager, ->{
    School.where(id: Users::SchoolManagement.kept
                                            .where(role: 'school_manager')
                                            .pluck(:school_id))
  }

  # TODO : the following scopes are not used in the codebase
  scope :from_departments_with_len, lambda { |department_str_array:, string_size: |
    zip_codes_as_str = Arel::Nodes::NamedFunction.new('CAST', [Arel.sql("schools.zipcode as varchar(255)")] )
    first_chars = Arel::Nodes::NamedFunction.new('LEFT', [zip_codes_as_str, string_size] )
    where(first_chars.in(department_str_array))
  }

  scope :from_departments, lambda { |department_str_array:|
    from_departments_with_len(
      department_str_array: department_str_array, string_size: 2
    ).or(
      from_departments_with_len(
        department_str_array: department_str_array, string_size: 3
      )
    )
  }

  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def agreement_address
    "Lycée #{name} - #{city}, #{zipcode}"
  end
  
  rails_admin do
    list do
      field :id
      field :name
      field :visible
      field :kind
      field :address do
        pretty_value do
          school = bindings[:object]
          "#{school.city} – CP #{school.zipcode} (#{school.department})"
        end
      end
      field :school_manager
      field :city do
        visible false
      end
      field :department do
        visible false
      end
      field :zipcode do
        visible false
      end
      scopes [:all, :with_manager, :without_manager]
    end

    edit do
      field :name
      field :visible
      field :kind, :enum do
        enum do
          School::VALID_TYPE_PARAMS
        end
      end
      field :code_uai

      field :coordinates do
        partial 'autocomplete_address'
      end

      field :class_rooms

      field :street do
        partial 'void'
      end
      field :zipcode do
        partial 'void'
      end
      field :city do
        partial 'void'
      end
      field :department do
        partial 'void'
      end
    end

    show do
      field :name
      field :visible
      field :kind
      field :street
      field :zipcode
      field :city
      field :department
      field :class_rooms
      field :internship_offers
      field :school_manager
    end

    export do
      field :name
      field :zipcode
      field :city
      field :department
      field :kind
      field :school_manager, :string do
        export_value do
          bindings[:object].school_manager.try(:name)
        end
      end
    end
  end


  def presenter
    Presenters::School.new(self)
  end

  def default_search_options
    {
      city: city,
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
    Department.find_by_name(department)&.academy&.email_domain
  end

  private

  def contract_label
    return "Public" if is_public?
    return "Privé sous contrat" if contract_code.in?(["30","31"])

    "Privé hors contrat"
  end

  def contract_code_label
    CONTRACT_CODES[contract_code]
  end

  def set_legal_status
    self.legal_status = contract_label
  end
end

