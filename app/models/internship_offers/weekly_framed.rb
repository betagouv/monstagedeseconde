# frozen_string_literal: true

module InternshipOffers
  class WeeklyFramed < InternshipOffer
    include RailsAdminInternshipOfferable

    after_initialize :init
    before_create :reverse_academy_by_zipcode

    # TODO: remove following since inherited
    attr_accessor :republish

    validates :street,
              :city,
              presence: true

    validates :max_candidates,
              numericality: { only_integer: true,
                              greater_than: 0,
                              less_than_or_equal_to: MAX_CANDIDATES_HIGHEST }
    validates :lunch_break, length: { minimum: 10, maximum: 200 }
    validate :schedules_check
    validate :enough_weeks

    after_initialize :init
    before_create :reverse_academy_by_zipcode

    #---------------------
    # fullfilled scope isolates those offers that have reached max_candidates
    #---------------------
    scope :fulfilled, lambda {
      joins(:stats).where('internship_offer_stats.remaining_seats_count < 1')
    }

    scope :uncompleted_with_max_candidates, lambda {
      offers_ar       = InternshipOffer.arel_table
      full_offers_ids = InternshipOffers::WeeklyFramed.fulfilled.ids

      where(offers_ar[:id].not_in(full_offers_ids))
    }

    scope :by_weeks, lambda { |weeks:|
      joins(:weeks).where(weeks: { id: weeks.ids })
    }

    scope :by_sector, lambda { |sector_ids:|
      where(sector_id: sector_ids)
    }

    scope :after_week, lambda { |week:|
      joins(:week).where('weeks.year > ? OR (weeks.year = ? AND weeks.number > ?)', week.year, week.year, week.number)
    }

    scope :after_current_week, lambda {
      after_week(week: Week.current)
    }

    def visible
      published? ? 'oui' : 'non'
    end

    def supplied_applications
      InternshipApplication.where(internship_offer_id: id)
                           .where(aasm_state: %w[approved convention_signed])
                           .count
    end

    def self.update_older_internship_offers
      to_be_unpublished = published.where('last_date < ?', Time.now.utc).to_a
      to_be_unpublished += published.joins(:stats).where('internship_offer_stats.remaining_seats_count < 1').to_a
      to_be_unpublished.uniq.each do |offer|
        print '.'
        # skip missing weeks validation
        offer.update_columns(
          aasm_state: 'need_to_be_updated',
          published_at: nil
        )
      end
    end

    def schedules_check
      return if schedules_ok?

      errors.add(:weekly_hours, :blank) if weekly_hours.blank?
      errors.add(:daily_hours, :blank) if daily_hours.blank?
    end

    def schedules_ok?
      weekly_hours_compacted = weekly_hours&.reject(&:blank?)
      daily_hours_compacted  = daily_hours&.reject { |_, v| v.first.blank? || v.second.blank? }
      return false if weekly_hours_compacted&.empty? && daily_hours_compacted&.empty?

      true
    end
  end
end
