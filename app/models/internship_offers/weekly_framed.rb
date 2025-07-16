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
    has_many :reserved_schools,
             dependent: :destroy
    has_many :schools,
             through: :reserved_schools
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

    # TODO: belongs_to a task not a model
    def self.update_older_internship_offers
      to_be_unpublished = where(aasm_state: %i[published need_to_be_updated splitted])
                          .where('last_date < ?', SchoolYear::Current.new.offers_beginning_of_period).to_a
      to_be_unpublished.each do |offer|
        print '.'
        # skip missing weeks validation and silent unpublishing
        offer.update_columns(
          aasm_state: 'unpublished',
          published_at: nil
        )
      end
      to_be_updated = published.joins(:stats).where('internship_offer_stats.remaining_seats_count < 1').to_a
      to_be_updated += published.where('last_date < ?', Time.now.utc).to_a
      to_be_updated.each do |offer|
        print '|'
        # skip missing weeks validation
        offer.update_columns(
          aasm_state: 'need_to_be_updated',
          published_at: nil
        )
      end
    end

    def has_weeks_before_school_year_start?
      start_week = Week.current_year_start_week
      weeks.any? { |week| week.id.in?(Week.strictly_before_week(week: start_week).ids) }
    end

    def has_weeks_after_school_year_start?
      start_week = Week.current_year_start_week
      weeks.any? { |week| week.id.in?(Week.after_week(week: start_week).ids) }
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
