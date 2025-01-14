# frozen_string_literal: true

require 'sti_preload'
class InternshipOffer < ApplicationRecord
  GUARD_PERIOD = 5.days
  PAGE_SIZE = 30
  # TODO : most probably to be the same field.
  EMPLOYER_DESCRIPTION_MAX_CHAR_COUNT = 1500
  DESCRIPTION_MAX_CHAR_COUNT = 1500
  MAX_CANDIDATES_HIGHEST = 6_000
  TITLE_MAX_CHAR_COUNT = 150
  DUPLICATE_WHITE_LIST = %w[type title sector_id max_candidates description
                            employer_name street zipcode city department entreprise_coordinates
                            employer_chosen_name all_year_long period grade_ids week_ids
                            entreprise_full_address internship_offer_area_id
                            is_public group school_id coordinates first_date last_date
                            siret internship_address_manual_enter lunch_break daily_hours
                            weekly_hours rep qpv].freeze

  include StiPreload
  include AASM

  # queries
  include Listable
  include FindableWeek
  include Zipcodable

  # Legacy now
  # include StepperProxy::InternshipOfferInfo
  # include StepperProxy::Organisation
  # include StepperProxy::HostingInfo
  # include StepperProxy::PracticalInfo
  # New stepper models
  include StepperProxy::InternshipOccupation
  include StepperProxy::Entreprise
  include StepperProxy::Planning

  # utils
  include Discard::Model
  include PgSearch::Model

  attr_accessor :republish, :grade_college, :grade_2e, :all_year_long, :period, :internship_type, :shall_publish

  # Other associations not defined in StepperProxy
  has_many :internship_applications, as: :internship_offer,
                                     foreign_key: 'internship_offer_id'

  belongs_to :internship_occupation, optional: true
  belongs_to :entreprise, optional: true
  belongs_to :planning, optional: true
  belongs_to :employer, polymorphic: true, optional: true
  belongs_to :internship_offer_area, optional: true, touch: true

  has_many :favorites
  has_many :users, through: :favorites
  has_many :users_internship_offers_histories, dependent: :destroy
  has_many :internship_offer_weeks,
           dependent: :destroy,
           foreign_key: :internship_offer_id,
           inverse_of: :internship_offer
  has_many :weeks, through: :internship_offer_weeks
  has_many :internship_offer_grades,
           dependent: :destroy,
           foreign_key: :internship_offer_id,
           inverse_of: :internship_offer
  has_many :grades, through: :internship_offer_grades

  has_one :stats, class_name: 'InternshipOfferStats', dependent: :destroy

  # accepts_nested_attributes_for :organisation, allow_destroy: true

  # Callbacks
  after_initialize :init

  before_save :sync_first_and_last_date,
              :reverse_academy_by_zipcode,
              :make_sure_area_is_set,
              :entreprise_used_name

  before_create :preset_published_at_to_now
  after_commit :sync_internship_offer_keywords
  after_create :create_stats
  after_update :update_stats

  paginates_per PAGE_SIZE

  # Délegate
  delegate :email, to: :employer, prefix: true, allow_nil: true
  delegate :phone, to: :employer, prefix: true, allow_nil: true
  delegate :name, to: :sector, prefix: true
  delegate :remaining_seats_count, to: :stats, allow_nil: true
  delegate :blocked_weeks_count, to: :stats, allow_nil: true
  delegate :total_applications_count, to: :stats, allow_nil: true
  delegate :approved_applications_count, to: :stats, allow_nil: true
  delegate :submitted_applications_count, to: :stats, allow_nil: true
  delegate :rejected_applications_count, to: :stats, allow_nil: true
  delegate :view_count, to: :stats, allow_nil: true
  delegate :total_male_applications_count, to: :stats, allow_nil: true
  delegate :total_female_applications_count, to: :stats, allow_nil: true
  delegate :total_male_approved_applications_count, to: :stats, allow_nil: true
  delegate :total_female_approved_applications_count, to: :stats, allow_nil: true
  delegate :update_need, to: :stats, allow_nil: true

  # Validations
  validate :check_missing_seats, if: :user_update?, on: :update
  validates :max_candidates, numericality: { only_integer: true,
                                             greater_than: 0,
                                             less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }

  # Scopes

  # public.config_search_keyword config is
  # this TEXT SEARCH CONFIGURATION is based on 2 keys concepts
  #   unaccent : which tokenize content without accent [search is also applied without accent]
  # .  french stem : which tokenize content for french FT
  # plus some customization to ignores
  #   email, url, host, file, uint, url_path, sfloat, float, numword, numhword, version;
  pg_search_scope :search_by_keyword,
                  against: {
                    title: 'A',
                    description: 'B',
                    employer_description: 'C'
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'public.config_search_keyword',
                      tsvector_column: 'search_tsv',
                      prefix: true
                    }
                  }

  # scope :public, -> { where is_public: true }
  scope :by_sector, lambda { |sector_id|
    where(sector_id:)
  }

  scope :with_seats, lambda {
    joins(:stats).where('internship_offer_stats.remaining_seats_count > 0')
  }

  scope :limited_to_department, lambda { |user:|
    where(department: user.department)
  }

  scope :limited_to_ministry, lambda { |user:|
    return none if user.ministries.empty?

    where(group_id: user.ministries.map(&:id))
  }

  scope :from_api, lambda {
    where.not(permalink: nil)
  }

  scope :not_from_api, lambda {
    where(permalink: nil)
  }

  scope :ignore_internship_restricted_to_other_schools, lambda { |school_id:|
    where(school_id: [nil, school_id])
  }

  scope :in_the_future, lambda {
    where('last_date > :now', now: Time.now)
  }

  scope :within_current_year, lambda {
    last_date = SchoolYear::Current.new.end_of_period + GUARD_PERIOD
    in_the_future.where('last_date <= :last_date', last_date:)
  }

  scope :weekly_framed, lambda {
    where(type: [InternshipOffers::WeeklyFramed.name,
                 InternshipOffers::Api.name])
  }

  scope :ignore_already_applied, lambda { |user:|
    where.not(id: InternshipApplication.where(user_id: user.id).map(&:internship_offer_id))
  }

  scope :fulfilled, lambda {
    # max_candidates == approved_applications_count
    at_stats = InternshipOfferStats.arel_table
    joins(:stats).where(at_stats[:remaining_seats_count].eq(0))
  }

  scope :uncompleted, lambda {
    at_stats = InternshipOfferStats.arel_table
    joins(:stats).where(at_stats[:remaining_seats_count].gt(0))
  }

  scope :filter_when_max_candidates_reached, lambda {
    uncompleted
  }

  # scope :specific_school_year, lambda { |school_year:|
  #   week_ids = Week.weeks_of_school_year(school_year:).pluck(:id)

  #   joins(:internship_offer_weeks)
  #     .where('internship_offer_weeks.week_id in (?)', week_ids)
  # }

  scope :with_school_year, lambda { |school_year:|
    where(school_year:)
  }

  scope :shown_to_employer, lambda {
    where(hidden_duplicate: false)
  }

  scope :with_weeks_next_year, lambda {
    next_year = SchoolYear::Current.new
                                   .next_year
                                   .end_of_period
                                   .year
    where(school_year: next_year)
  }

  scope :by_department, ->(departments) { where(department: departments) }

  aasm do
    state :published, initial: true
    state :removed,
          :unpublished,
          :need_to_be_updated,
          :splitted

    event :publish do
      transitions from: %i[unpublished need_to_be_updated],
                  to: :published, after: proc { |*_args|
                                           update!("published_at": Time.now.utc)
                                           if employer.internship_offers.count == 1
                                             UpdateHubspotContactJob.perform_later(employer_id)
                                           end
                                         }
    end

    event :remove do
      transitions from: %i[published need_to_be_updated unpublished],
                  to: :removed, after: proc { |*_args|
                                         update!(published_at: nil)
                                       }
    end

    event :unpublish do
      transitions from: %i[published need_to_be_updated],
                  to: :unpublished, after: proc { |*_args|
                                             update!(published_at: nil)
                                           }
    end

    event :split do
      transitions from: %i[published need_to_be_updated unpublished],
                  to: :splitted, after: proc { |*_args|
                                          # update!(published_at: nil) TODO
                                        }
    end

    event :need_update do
      transitions from: %i[published unpublished need_to_be_updated],
                  to: :need_to_be_updated, after: proc { |*_args|
                                                    update!(published_at: nil)
                                                  }
    end
  end

  # -------------------------
  # Methods
  # -------------------------

  def self.period_labels(school_year:)
    SchoolTrack::Seconde.period_labels(school_year:)
  end

  def self.current_period_labels
    period_labels(school_year: SchoolYear::Current.year_in_june)
  end

  def current_period_label
    Presenters::WeekList.new(weeks: weeks).to_range_as_str
  end

  def period_label
    InternshipOffer.period_labels(school_year:).values[period]
  end

  def weeks_count
    internship_offer_weeks.count
  end

  def first_monday
    presenter.first_monday
  end

  def reserved_to_school?
    school.present?
  end
  # def last_monday
  #   I18n.l internship_offer_weeks.last.week.week_date,
  #           format: Week::WEEK_DATE_FORMAT
  # end

  def has_spots_left?
    max_candidates > internship_applications.approved.count
  end

  def is_fully_editable?
    internship_applications.empty?
  end

  def two_weeks_long?
    weeks & SchoolTrack::Seconde.both_weeks == SchoolTrack::Seconde.both_weeks
  end

  def seconde_school_track_week_1?
    weeks & SchoolTrack::Seconde.both_weeks == SchoolTrack::Seconde.first_week
  end

  def seconde_school_track_week_2?
    weeks & SchoolTrack::Seconde.both_weeks == SchoolTrack::Seconde.second_week
  end

  def fits_for_seconde?
    grades.select { |grade| grade.seconde? }.any? &&
      weeks.any? { |w| w.id.in?(SchoolTrack::Seconde.both_weeks.map(&:id)) }
  end

  def fits_for_troisieme_or_quatrieme?
    grades.select { |grade| grade.troisieme_or_quatrieme? }.any? &&
      weeks.any? { |w| w.id.in?(SchoolTrack::Troisieme.selectable_on_school_year_weeks.map(&:id)) }
  end

  #
  # callbacks
  #
  def sync_first_and_last_date
    ordered_weeks = weeks.to_a.sort_by(&:id)
    self.first_date = ordered_weeks.first&.week_date
    self.last_date = ordered_weeks.last&.week_date&.+ 4.days
  end

  #
  # inherited
  #
  # def duplicate
  #   internship_offer = super
  #   internship_offer.week_ids = week_ids
  #   internship_offer
  # end

  def split_in_two
    print '.'

    internship_offer = duplicate
    internship_offer.remaining_seats_count = max_candidates
    internship_offer.employer = employer
    unless internship_offer.valid?
      raise StandardError.new "##{internship_offer.errors.full_messages} - on #{internship_offer.errors.full_messages}"
    end

    internship_offer.save

    self.hidden_duplicate = true
    split!
    save!

    internship_offer
  end

  def shown_as_masked?
    !published?
  end

  def departement
    Department.lookup_by_zipcode(zipcode:)
  end

  def operator
    return nil unless from_api?

    employer.operator
  end

  def from_api?
    permalink.present?
  end

  def init
    self.school_year ||= SchoolYear::Current.year_in_june
  end

  def already_applied_by_student?(student)
    !!internship_applications.where(user_id: student.id).first
  end

  def total_no_gender_applications_count
    total_applications_count - total_male_applications_count - total_female_applications_count
  end

  def anonymize
    fields_to_reset = {
      tutor_name: 'NA',
      tutor_phone: 'NA',
      tutor_email: 'NA',
      tutor_role: 'NA',
      title: 'NA',
      description: 'NA',
      employer_website: 'NA',
      street: 'NA',
      employer_name: 'NA',
      employer_description: 'NA'
    }
    update(fields_to_reset)
    discard
  end

  def duplicate
    generate_offer_from_attributes(DUPLICATE_WHITE_LIST)
  end

  def duplicate_without_location
    white_list_without_location = DUPLICATE_WHITE_LIST - %w[street city zipcode coordinates]

    generate_offer_from_attributes(white_list_without_location)
  end

  def update_from_internship_occupation
    return unless internship_occupation

    # self.employer_name = organisation.employer_name
    # self.employer_website = organisation.employer_website
    self.description = internship_occupation.description
    # self.siret = organisation.siret
    # self.group_id = organisation.group_id
    # self.is_public = organisation.is_public
    # self.internship_street = internship_occupation.street
    # self.internship_zipcode = internship_occupation.zipcode
    # self.internship_city = internship_occupation.city
    # self.internship_coordinates = internship_occupation.coordinates
    # self.internship_offer_area_id = internship_occupation.internship_offer_area_id
  end

  def update_from_organisation
    nil unless organisation

    #   self.employer_name = organisation.employer_name
    #   self.employer_website = organisation.employer_website
    #   self.employer_description = organisation.employer_description
    #   self.siret = organisation.siret
    #   self.group_id = organisation.group_id
    #   self.is_public = organisation.is_public
  end

  def generate_offer_from_attributes(white_list)
    offer = InternshipOffer.new(attributes.slice(*white_list))
    offer.weeks = weeks
    offer.grades = grades
    offer
  end

  def preset_published_at_to_now
    self.published_at = Time.now
  end

  def reverse_academy_by_zipcode
    self.academy = Academy.academy_name_by_zipcode(zipcode:)
  end

  def sync_internship_offer_keywords
    previous_title, new_title = title_previous_change
    previous_description, new_description = description_previous_change
    previous_employer_description, new_employer_description = employer_description_previous_change

    if [previous_title != new_title,
        previous_description != new_description,
        previous_employer_description != new_employer_description].any?
      SyncInternshipOfferKeywordsJob.perform_later
    end
  end

  # def with_applications?
  #   self.internship_applications.count.positive?
  # end

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end

  def daily_planning?
    return false if daily_hours.blank?

    daily_hours.except('samedi').values.flatten.any? { |v| !v.blank? }
  end

  def presenter
    Presenters::InternshipOffer.new(self)
  end

  def is_favorite?(user)
    return false if user.nil?

    user.favorites.exists?(internship_offer_id: id)
  end

  def update_all_favorites
    return unless approved_applications_count >= max_candidates || Time.now > last_date

    Favorite.where(internship_offer_id: id).destroy_all
  end

  def no_remaining_seat_anymore?
    remaining_seats_count.zero?
  end

  def requires_updates?
    may_need_update? && no_remaining_seat_anymore?
  end

  def requires_update_at_toggle_time?
    return false if published?

    no_remaining_seat_anymore?
  end

  def approved_applications_current_school_year
    internship_applications.approved.current_school_year
  end

  def log_view(user)
    history = UsersInternshipOffersHistory.find_or_initialize_by(internship_offer: self, user:)
    history.views += 1
    history.save
  end

  def log_apply(user)
    history = UsersInternshipOffersHistory.find_or_initialize_by(internship_offer: self, user:)
    history.application_clicks += 1
    history.save
  end

  def create_stats
    stats = InternshipOfferStats.create(internship_offer: self)
    stats.recalculate
  end

  def update_stats
    stats.recalculate
  end

  def check_for_missing_seats
    return unless no_remaining_seat_anymore?

    errors.add(:max_candidates, 'Augmentez Le nombre de places disponibles pour accueillir des élèves')
  end

  def check_missing_seats
    # different from published? since published? checks the database and the former state of the object
    return false if published_at.nil?
    return false if republish.nil?

    check_for_missing_seats
  end

  def user_update?
    # user_update == 'true'
  end

  def weeks_api_formatted
    Presenters::WeekList.new(weeks: weeks).to_api_formatted
  end

  protected

  def make_sure_area_is_set
    return if internship_offer_area_id.present?

    if employer&.current_area_id.nil?
      Rails.logger.error('no internship_offer_area with ' \
                         "internship_offer_id: #{id} and " \
                         "employer_id: #{employer_id}")
    end
    self.internship_offer_area_id = employer.current_area_id
    Rails.logger.warn('default internship_offer_area with ' \
                         "internship_offer_id: #{id} and " \
                         "employer_id: #{employer_id}")
  end
end
