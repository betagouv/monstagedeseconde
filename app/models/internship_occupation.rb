class InternshipOccupation < ApplicationRecord
  include StepperProxy::InternshipOccupation

  # for ACL
  belongs_to :employer, class_name: 'User' # , optional: true
  has_one :entreprise, dependent: :destroy
  has_one :planning, dependent: :destroy
  has_one :internship_offer, inverse_of: :internship_occupation, dependent: :destroy

  # linked via stepper
  has_many :internship_offers

  # call back after update
  after_update :update_internship_offer

  def update_internship_offer
    # internship_offer.update_from_organisation if internship_offer
    internship_offer.update_from_internship_occupation if internship_offer
  end

  def from_api?
    false
  end

  def duplicate
    dup.tap do |new_internship_occupation|
      new_internship_occupation.employer = employer
      new_internship_occupation.internship_street = internship_street
      new_internship_occupation.internship_zipcode = internship_zipcode
      new_internship_occupation.internship_city = internship_city
      # new_internship_occupation.siret = siret
      # new_internship_occupation.manual_enter = manual_enter
      new_internship_occupation.internship_coordinates = internship_coordinates
      new_internship_occupation.description = description
      # new_internship_occupation.employer_website = employer_website
      # new_internship_occupation.employer_name = employer_name
      # new_internship_occupation.group_id = group_id
      # new_internship_occupation.is_public = is_public
    end
  end
end
