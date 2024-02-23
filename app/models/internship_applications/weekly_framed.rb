module InternshipApplications
  # wraps weekly logic
  class WeeklyFramed < InternshipApplication

    after_save :update_all_counters

    validates :student, uniqueness: { scope: [:internship_offer_id, :week_id] }

    before_validation :at_most_one_application_per_student?, on: :create
    before_validation :internship_offer_has_spots_left?, on: :create


    def approvable?
      return false unless internship_offer.has_spots_left?

      true
    end

    def internship_offer_has_spots_left?
      errors.add(:internship_offer, :has_no_spots_left) unless internship_offer.has_spots_left?
    end

    def at_most_one_application_per_student?
      if internship_offer
          .internship_applications
          .where(user_id: user_id)
          .count
          .positive?

        errors.add(:user_id, :duplicate)
      end
    end

    def remaining_seats_count
      max_places      = internship_offer.max_candidates
      reserved_places = internship_offer.internship_applications.approved.count
      max_places - reserved_places
    end
  end
end
