class Invitation < ApplicationRecord
  # Associations
  belongs_to :user, class_name: 'Users::SchoolManagement', foreign_key: 'user_id', inverse_of: :invitations

  # Callbacks
  before_save :check_academies
  belongs_to :author,
             class_name: 'Users::SchoolManagement',
             foreign_key: 'user_id'
  # Delegate methods
  delegate :school, to: :author

  # Validations
  normalizes :email, with: ->(email) { email.strip.downcase }, apply_to_nil: false
  validates :first_name,
            :last_name,
            :email,
            :user_id,
            presence: true
  validates :email, uniqueness: { message: 'a déjà été invité' }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP,
                              message: 'doit être une adresse email valide' }

  validate  :official_email_address

  # Scopes
  scope :for_people_with_no_account_in, lambda { |school_id:|
    where.not(email: Users::SchoolManagement.kept
                                            .where(school_id: school_id)
                                            .pluck(:email))
  }

  scope :invited_by, ->(user_id:) { where(user_id: user_id) }
  # --------
  def presenter
    @presenter ||= Presenters::Invitation.new(self)
  end

  def inviter_school_uai_code
    user.school.code_uai
  end

  private

  # validators
  def official_email_address
    return unless email.present?

    return if email.split('@').second != school.department.email_domain
    errors.add(
      :email,
      "L'adresse email utilisée doit être officielle.<br>ex: XXXX@ac-academie.fr".html_safe
    )
  end

  def check_academies
    return unless email.split('@').second == user.school.email_domain_name

    errors.add(:email, "L'académie dans l'adresse email doit correspondre à celle de celui qui vous a invité")
  end
end
