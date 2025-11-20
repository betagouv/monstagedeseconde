module InternshipApplications
  # wraps weekly logic
  class WeeklyFramed < InternshipApplication
    after_save :update_all_counters

    before_validation :at_most_one_application_per_student?, on: :create
    before_validation :internship_offer_has_spots_left?, on: :create

    validate :unique_student_application_per_week, on: :create

    def unique_student_application_per_week
      return if weeks.blank? || student.blank? || internship_offer.blank?

      duplicate = InternshipApplication.joins(:weeks)
                                      .where(internship_offer_id: internship_offer_id,
                                              user_id: user_id,
                                              weeks: { id: weeks.ids })
                                      .exists?
      errors.add(:base, :duplicate) if duplicate
    end

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
