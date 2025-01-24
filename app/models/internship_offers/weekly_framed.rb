# frozen_string_literal: true

module InternshipOffers
  class WeeklyFramed < InternshipOffer
    include RailsAdminInternshipOfferable

    # TODO: remove following since inherited
    attr_accessor :republish

    #---------------------
    after_initialize :init
    before_create :reverse_academy_by_zipcode
    before_save :copy_entreprise_full_address
    after_commit :split_in_two, if: :to_be_splitted?
    #---------------------
    validates :street,
              :city,
              presence: true
    validates :contact_phone,
              format: { with: Regexp.new(ApplicationController.helpers.field_phone_pattern),
                        message: 'Le numéro de téléphone doit être composé de 10 chiffres' },
              unless: :from_api?

    validates :max_candidates,
              numericality: { only_integer: true,
                              greater_than: 0,
                              less_than_or_equal_to: MAX_CANDIDATES_HIGHEST }
    validates :lunch_break, length: { minimum: 8, maximum: 250 }
    validate :schedules_check

    #---------------------
    has_one :mother,
            class_name: 'InternshipOffer',
            foreign_key: 'mother_id',
            dependent: :nullify
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

    def to_be_splitted?
      if hidden_duplicate?
        false
      elsif mother_id.present?
        mother = InternshipOffer.find_by(mother_id: mother_id)
        mother.splitted?
      else
        has_weeks_in_the_past? && has_weeks_in_the_future?
      end
    end

    def has_weeks_in_the_past?
      start_week = Week.current_year_start_week
      weeks.any? { |week| week.id.in?(Week.before_week(week: start_week).ids) }
    end

    # TODO
    # make a before and after block to be reused

    def has_weeks_in_the_future?
      start_week = Week.current_year_start_week
      weeks.any? { |week| week.id.in?(Week.after_week(week: start_week).ids) }
    end

    def split_in_two
      new_internship_offer = dup

      new_internship_offer.hidden_duplicate = false
      new_internship_offer.mother_id = id
      new_internship_offer.weeks = weeks & Week.weeks_of_school_year(school_year: Week.current_year_start_week.year)
      new_internship_offer.grades = grades
      new_internship_offer.weekly_hours = weekly_hours
      new_internship_offer.save!
      # stats have to exist before intenship_applications is moved
      new_internship_offer.internship_applications = []
      new_internship_offer.save!
      new_internship_offer.publish! unless new_internship_offer.published?

      self.hidden_duplicate = true
      self.weeks = weeks & Week.of_past_school_years
      self.published_at = nil
      self.aasm_state = 'splitted'
      save! && new_internship_offer
    end

    def child
      InternshipOffer.find_by(mother_id: id)
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

    def copy_entreprise_full_address
      self.entreprise_full_address = entreprise_chosen_full_address.blank? ? entreprise_full_address : entreprise_chosen_full_address
    end
  end
end
