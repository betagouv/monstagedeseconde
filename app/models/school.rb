# frozen_string_literal: true

require 'mini_magick'
require 'tempfile'

class School < ApplicationRecord
  include Nearbyable
  include Zipcodable
  include SchoolUsersAssociations

  has_many :class_rooms, dependent: :destroy
  has_many :internship_offers, dependent: :nullify
  has_many :internship_applications, through: :students
  has_many :internship_agreements, through: :internship_applications
  has_many :plannings, dependent: :destroy
  has_many :dedicated_internship_offers, foreign_key: :school_id, dependent: :nullify, class_name: 'InternshipOffer'
  has_many :school_internship_weeks, dependent: :destroy
  has_many :weeks, through: :school_internship_weeks
  belongs_to :department, optional: true
  has_one_attached :signature

  # has_rich_text :agreement_conditions_rich_text

  validates :city, :name, :code_uai, presence: true
  validates :code_uai, uniqueness: { message: 'Ce code UAI est déjà utilisé, le lycée est déjà enregistré' }
  validates :zipcode, zipcode: { country_code: :fr }
  validates :signature,
            content_type: {
              in: ['image/jpeg', 'image/png', 'application/pdf'],
              message: 'doit être au format JPEG, PNG ou PDF'
            },
            if: -> { signature.attached? }
  validates :signature,
            size: {
              less_than: 5.megabytes,
              message: 'doit être inférieure à 5 Mo'
            },
            if: -> { signature.attached? }

  # Callbacks
  before_save :set_legal_status
  after_commit :convert_pdf_to_png, if: :needs_pdf_conversion?

  CONTRACT_CODES = {
    '10' => 'HORS CONTRAT',
    '30' => "CONTRAT D'ASSOCIATION TOUTES CLASSES",
    '31' => 'CONTRAT ASSOCIATION PARTIE DES CLASSES',
    '99' => 'SANS OBJET'
  }
  VALID_TYPE_PARAMS = %w[rep rep_plus].freeze
  SCHOOL_TYPES = %w[college lycee].freeze

  scope :with_manager, lambda {
                         left_joins(:school_manager)
                           .group('schools.id')
                           .having('count(users.id) > 0')
                       }

  scope :with_school_manager, lambda {
    School.where(id: Users::SchoolManagement.kept
                                            .where(role: 'school_manager')
                                            .pluck(:school_id))
  }

  scope :internship_weeks_nearby, lambda { |latitude:, longitude:, radius:|
    joins(school_internship_weeks: :week)
      .nearby(latitude:, longitude:, radius:)
  }

  def self.nearby_school_weeks(latitude:, longitude:, radius:)
    internship_weeks_nearby(latitude:, longitude:, radius:)
      .pluck(:week_id)
      .tally
      .transform_keys { |week_id| "school-week-#{week_id}".to_sym }
  end

  def select_text_method
    "#{name} - #{city} - #{zipcode}"
  end

  def agreement_address
    "#{presenter.school_name} - #{city}, #{zipcode}"
  end

  def has_weeks_on_current_year?
    weeks.try(:selectable_on_school_year).try(:exists?)
  end

  rails_admin do
    list do
      field :id
      field :name
      field :visible
      field :code_uai
      field :address do
        pretty_value do
          school = bindings[:object]
          "#{school.city} – CP #{school.zipcode} (#{school.department.name})"
        end
      end
      field :school_manager do
        pretty_value do
          school = bindings[:object]
          school.school_manager.try(:presenter).try(:full_name)
        end
      end
      field :city do
        visible false
      end
      field :department do
        visible false
      end
      field :zipcode do
        visible false
      end
    end

    show do
      field :code_uai
      field :name
      field :visible
      field :rep_kind
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
      field :rep_kind
      field :school_manager, :string do
        export_value do
          bindings[:object].school_manager.try(:name)
        end
      end
    end
  end

  def college?
    school_type == 'college'
  end

  def management_representative
    school_management_users = Users::SchoolManagement.kept.where(school_id: id)
    return nil if school_management_users.empty?

    %w[admin_officer school_manager cpe other teacher].each do |role|
      return school_management_users.find_by(role: role) if school_management_users.any? { |user| user.role == role }
    end
    nil
  end

  def presenter
    Presenters::School.new(self)
  end

  def default_search_options(user)
    school_params = {
      city:,
      latitude: coordinates.lat,
      longitude: coordinates.lon,
      radius: Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER
    }
    school_params.merge!(grade_id: user.grade_id) if user.grade_id.present?
    school_params
  end

  def has_staff?
    users.where(role: ['teacher', 'other'])
         .count
         .positive?
  end

  def to_s
    name
  end

  def email_domain_name
    department.academy.email_domain
  end

  def off_constraint_school_weeks(grade)
    return Week.both_school_track_selectable_weeks if grade.nil?

    case grade.short_name
    when 'troisieme', 'quatrieme'
      SchoolTrack::Troisieme
    when 'seconde'
      SchoolTrack::Seconde
    end.selectable_from_now_until_end_of_school_year
  end

  def school_manager
    school_managers.first
  end

  def teacher
    teachers.first
  end

  def other
    others.first
  end

  def cpe
    cpes.first
  end

  def admin_officer
    admin_officers.first
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

  def needs_pdf_conversion?
    signature.attached? && signature.content_type == 'application/pdf'
  end

  def convert_pdf_to_png
    return unless signature.attached? && signature.content_type == 'application/pdf'

    begin
      temp_pdf = Tempfile.new(['signature', '.pdf'])
      temp_pdf.binmode
      temp_pdf.write(signature.download)
      temp_pdf.close

      # Convert to PNG
      image = MiniMagick::Image.new(temp_pdf.path)
      image.format 'png'

      # Reattach as PNG
      signature.attach(
        io: StringIO.new(image.to_blob),
        filename: signature.filename.to_s.sub('.pdf', '.png'),
        content_type: 'image/png'
      )
    rescue StandardError => e
      Rails.logger.error "Erreur lors de la conversion PDF->PNG: #{e.message}"
      errors.add(:signature, "n'a pas pu être convertie en PNG")
    ensure
      # Cleanup
      temp_pdf.unlink if temp_pdf
    end
  end
end
