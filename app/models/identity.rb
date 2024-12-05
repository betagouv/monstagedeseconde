class Identity < ApplicationRecord
  # Relations
  belongs_to :user, optional: true
  belongs_to :school
  belongs_to :class_room, optional: true

  # Validations
  validates :first_name, :last_name, :birth_date, :token,
            presence: true

  before_validation :generate_token, unless: :token

  def archive
    update_columns(
      first_name: ::FFaker::Name.first_name,
      last_name: ::FFaker::Name.last_name,
      birth_date: ::FFaker::Date.birthday(min_age: 18, max_age: 65),
      class_room_id: nil,
      anonymized: true
    )
  end

  private

  def generate_token
    self.token = SecureRandom.hex(12)
  end
end
