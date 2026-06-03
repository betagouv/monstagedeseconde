# frozen_string_literal: true

module FindableWeek
  extend ActiveSupport::Concern

  included do
    scope :by_weeks, lambda { |weeks:|
      selected_ids = weeks.ids
      next none if selected_ids.empty?

      offers_with_extra_week = InternshipOfferWeek.where.not(week_id: selected_ids)
                                                  .select(:internship_offer_id)
      joins(:weeks).where(weeks: { id: selected_ids })
                   .where.not(id: offers_with_extra_week)
    }

    scope :older_than, lambda { |week:|
      joins(:weeks).where('weeks.year < :year OR (weeks.year = :year AND weeks.number >= :number)',
                          year: week.year, number: week.number)
    }

    scope :in_the_past, lambda {
      where('last_date < ?', Date.today)
    }

    scope :in_the_future, lambda {
      where('last_date > :now', now: Time.now)
    }

    scope :more_recent_than, lambda { |week:|
      joins(:weeks).where('weeks.year > :year OR (weeks.year = :year AND weeks.number >= :number)',
                          year: week.year, number: week.number)
    }
  end
end
