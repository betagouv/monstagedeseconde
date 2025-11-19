class Signature < ApplicationRecord
  has_one_attached :signature_image
  SIGNATURE_STORAGE_DIR = 'signature_storage'

  enum signatory_role: {
    school_manager: 'school_manager',
    employer: 'employer',
    cpe: 'cpe',
    admin_officer: 'admin_officer',
    other: 'other',
    teacher: 'teacher',
    student: 'student',
    student_legal_representative: 'student_legal_representative'
  }

  FR_SIGNATORY_ROLE = {
    school_manager: "Responsable de l'établissement",
    employer: "Représentant de l'entreprise",
    cpe: 'CPE',
    admin_officer: 'Gestionnaire',
    other: 'Autre',
    teacher: 'Enseignant',
    student: 'Élève',
    student_legal_representative: 'Représentant légal'
  }.freeze

  SCHOOL_MANAGEMENT_SIGNATORY_ROLE = %w[
    school_manager
    cpe
    admin_officer
    other
    teacher
  ].freeze

  REQUESTED_SIGNATURES_COUNT = 4

  belongs_to :internship_agreement
  belongs_to :signator, class_name: 'User', foreign_key: 'user_id'
  validates :signatory_role, inclusion: { in: signatory_roles.values }
  validates :signatory_ip,
            :signature_date,
            :internship_agreement_id,
            :user_id,
            presence: true
  validates :signature_phone_number,
            presence: true,
            if: :employer_signatory_role?,
            format: { with: /\A\+?[0-9]{10,}\z/, message: 'doit contenir au moins 10 chiffres' }
  validates :signature_image,
            presence: true,
            if: :employer_signatory_role?

  validate :no_double_signature?

  delegate :student,        to: :internship_agreement
  delegate :employer,       to: :internship_agreement
  delegate :school_manager, to: :internship_agreement

  def self.file_path(user:, internship_agreement_id:)
    "#{SIGNATURE_STORAGE_DIR}/signature-#{Rails.env}-#{user.signatory_role}" \
    "-#{internship_agreement_id}.png"
  end

  #----------------------------------------------------------------------------

  def signatures_count
    Signature.where(internship_agreement_id: internship_agreement_id)
             .count
  end

  def all_signed?
    if Flipper.enabled?(:student_signature)
      signatures_count == REQUESTED_SIGNATURES_COUNT
    else
      signatures_count == REQUESTED_SIGNATURES_COUNT - 2
    end && internship_agreement.signed_by_employer?
  end

  def attach_signature!(io:, filename:, content_type:)
    image = MiniMagick::Image.read(io.read)
    io.rewind

    unless image.type.downcase.in?(%w[jpeg jpg png gif bmp tiff webp])
      raise ArgumentError, "Le fichier n'est pas une image reconnue (type détecté : #{image.type})"
    end

    signature_image.attach(io: io,
                           filename: filename,
                           content_type: content_type) && true
  end

  def presenter
    Presenters::Signature.new(signature: self)
  end

  private

  def no_double_signature?
    signed_roles = Signature.where(internship_agreement_id: internship_agreement_id)
                            .pluck(:signatory_role)
    return unless signed_roles.include?(signatory_role)

    errors.add(:signatory_role, "#{FR_SIGNATORY_ROLE[signatory_role.to_sym]} a déjà signé")
  end

  def employer_signatory_role?
    signatory_role == 'employer'
  end
end
