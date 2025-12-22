# frozen_string_literal: true

module Builders
  class MultiInternshipOfferBuilder < BuilderBase
    def create_from_stepper(user:, multi_planning:)
      yield callback if block_given?
      authorize :create, InternshipOffers::Multi

      multi_coordinator = multi_planning.multi_coordinator
      multi_activity = multi_coordinator.multi_activity
      multi_corporation = multi_coordinator.multi_corporation
      
      # Use coordinates from first corporation
      first_corporation = multi_corporation.corporations.first
      coordinates = first_corporation&.internship_coordinates || RGeo::Geographic.spherical_factory(srid: 4326).point(0, 0)
      sector = multi_coordinator.sector

      internship_attributes = {
        employer_id: user.id,
        employer_type: 'User',
        title: multi_activity.title,
        description: multi_activity.description,
        employer_name: multi_coordinator.employer_chosen_name,
        employer_chosen_name: multi_coordinator.employer_chosen_name,
        street: multi_coordinator.street,
        zipcode: multi_coordinator.zipcode,
        city: multi_coordinator.city,
        sector_id: sector.id,
        contact_phone: multi_coordinator.phone,
        max_candidates: multi_planning.max_candidates,
        weekly_hours: multi_planning.weekly_hours,
        daily_hours: multi_planning.daily_hours,
        lunch_break: multi_planning.lunch_break,
        rep: multi_planning.rep,
        qpv: multi_planning.qpv,
        multi_corporation_id: multi_corporation.id,
        weeks: multi_planning.weeks,
        grades: multi_planning.grades,
        school_id: multi_planning.school_id,
        internship_offer_area_id: user.current_area_id,
        is_public: sector.name == 'Fonction publique',
        coordinates: coordinates,
        entreprise_coordinates: coordinates,
        entreprise_full_address: "#{multi_coordinator.street} #{multi_coordinator.zipcode} #{multi_coordinator.city}",
        entreprise_chosen_full_address: "#{multi_coordinator.street} #{multi_coordinator.zipcode} #{multi_coordinator.city}",
        first_date: multi_planning.weeks.min_by(&:beginning_of_week)&.beginning_of_week,
        last_date: multi_planning.weeks.max_by(&:beginning_of_week)&.end_of_week
      }
      
      internship_offer = InternshipOffers::Multi.new(internship_attributes)
      internship_offer.save!

      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end
    
    private
    
    attr_reader :callback, :user, :ability, :context

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end
  end
end

