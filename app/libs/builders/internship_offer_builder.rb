# frozen_string_literal: true

module Builders
  # wrap internship offer creation logic / failure for API/web usage
  class InternshipOfferBuilder < BuilderBase
    # called by dashboard/stepper/practical_info#create during creating with steps

    def create_from_stepper(user:, planning:)
      yield callback if block_given?
      authorize :create, model
      entreprise = planning.entreprise
      internship_occupation = entreprise.internship_occupation
      internship_attributes = {}.merge(preprocess_internship_occupation_to_params(internship_occupation))
                                .merge(preprocess_entreprise_to_params(entreprise))
                                .merge(preprocess_planning_to_params(planning))
                                .merge(employer_id: user.id, employer_type: 'User')
                                .merge(
                                  internship_occupation_id: internship_occupation.id,
                                  entreprise_id: entreprise.id,
                                  planning_id: planning.id,
                                  group_id: entreprise.group_id,
                                  internship_offer_area_id: user.current_area_id
                                )
      internship_offer = model.new(**internship_attributes)
      internship_offer.save!
      DraftedInternshipOfferJob.set(wait: 1.week)
                               .perform_later(internship_offer_id: internship_offer.id)
      callback.on_success.try(:call, internship_offer)
    rescue ArgumentError => e
      Rails.logger.error "Impossible de créer cette offre. offreur: #{user.id} | #{e&.message}"
      callback.on_failure.try(:call, @entreprise)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    # TODO : is this still used ?
    def update_from_stepper(internship_offer, user:, planning:)
      yield callback if block_given?
      authorize :update, model
      internship_offer.update(
        {}.merge(preprocess_internship_occupation_to_params(planning.entreprise.internship_occupation))
          .merge(preprocess_entreprise_to_params(planning.entreprise))
          .merge(preprocess_planning_to_params(planning))
          .except(:employer_id)
      )
      internship_offer.save!
      DraftedInternshipOfferJob.set(wait: 1.week)
                               .perform_later(internship_offer_id: internship_offer.id)
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    end

    # called by internship_offers#create (duplicate), api/internship_offers#create
    def create(params:)
      yield callback if block_given?
      authorize :create, model
      create_params = preprocess_api_params(params)
      internship_offer = model.new(create_params)

      unless from_api?
        internship_offer = Dto::PlanningAdapter.new(instance: internship_offer,
                                                    params: create_params,
                                                    current_user: user)
                                               .manage_planning_associations
                                               .instance
      end
      internship_offer.internship_offer_area_id = user.current_area_id
      internship_offer.aasm_state = 'published' if internship_offer.may_publish?
      internship_offer.save!
      callback.on_success.try(:call, internship_offer)
    rescue ActiveRecord::RecordInvalid => e
      if duplicate?(e.record)
        callback.on_duplicate.try(:call, e.record)
      else
        callback.on_failure.try(:call, e.record)
      end
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def update(instance:, params:)
      yield callback if block_given?
      authorize :update, instance
      instance.assign_attributes(params)
      if from_api?
        instance.attributes = preprocess_api_params(params)
      else
        instance = Dto::PlanningAdapter.new(instance:, params:, current_user: user)
                                       .manage_planning_associations
                                       .instance
      end
      instance = deal_with_max_candidates_change(params:, instance:)

      if from_api?
        instance.reset_publish_states
      elsif instance.shall_publish
        instance.published_at = Time.zone.now
        instance.aasm_state = :published
      end

      instance.save! # this may set aasm_state to need_to_be_updated state
      callback.on_success.try(:call, instance)
    rescue ActiveRecord::RecordInvalid => e
      callback.on_failure.try(:call, e.record)
    rescue ArgumentError => e
      callback.on_argument_error.try(:call, e)
    end

    def discard(instance:)
      yield callback if block_given?
      authorize :discard, instance
      instance.discard!
      callback.on_success.try(:call, instance)
    rescue Discard::RecordNotDiscarded
      callback.on_failure.try(:call, instance)
    end

    private

    attr_reader :callback, :user, :ability, :context

    def initialize(user:, context:)
      @user = user
      @context = context
      @ability = Ability.new(user)
      @callback = InternshipOfferCallback.new
    end

    def preprocess_api_params(params)
      return params unless from_api?

      opts = { params: params,
               user: user }

      Dto::ApiParamsAdapter.new(**opts)
                           .sanitize
    end

    def preprocess_internship_occupation_to_params(internship_occupation)
      {
        title: internship_occupation.title,
        description: internship_occupation.description,
        street: internship_occupation.street,
        zipcode: internship_occupation.zipcode,
        city: internship_occupation.city,
        department: internship_occupation.department,
        coordinates: internship_occupation.coordinates,
        employer_id: internship_occupation.employer_id
      }
    end

    def preprocess_entreprise_to_params(entreprise)
      {
        siret: entreprise.siret,
        is_public: entreprise.is_public,
        employer_name: entreprise.employer_name,
        employer_chosen_name: entreprise.employer_chosen_name,
        group_id: entreprise.group_id,
        sector_id: entreprise.sector_id,
        entreprise_full_address: entreprise.entreprise_full_address,
        entreprise_chosen_full_address: entreprise.entreprise_chosen_full_address,
        entreprise_coordinates: entreprise.entreprise_coordinates,
        workspace_conditions: entreprise.workspace_conditions,
        workspace_accessibility: entreprise.workspace_accessibility,
        internship_address_manual_enter: entreprise.internship_address_manual_enter
      }
    end

    def preprocess_planning_to_params(planning)
      {
        max_candidates: planning.max_candidates,
        max_students_per_group: planning.max_students_per_group,
        weekly_hours: planning.weekly_hours,
        daily_hours: planning.daily_hours,
        school_id: planning.school_id,
        employer_id: planning.employer_id,
        lunch_break: planning.lunch_break,
        weeks: planning.weeks,
        grades: planning.grades,
        rep: planning.rep,
        qpv: planning.qpv
      }
    end

    def from_api?
      context == :api
    end

    def deal_with_max_candidates_change(params:, instance:)
      return instance unless max_candidates_will_change?(params: params, instance: instance)

      approved_applications_count = instance.internship_applications.approved.count
      next_max_candidates = params[:max_candidates].to_i

      if next_max_candidates < approved_applications_count
        error_message = 'Impossible de réduire le nombre de places ' \
                        'de cette offre de stage car ' \
                        'vous avez déjà accepté plus de candidats que ' \
                        'vous n\'allez leur offrir de places.'
        instance.errors.add(:max_candidates, error_message)
        raise ActiveRecord::RecordInvalid, instance
      end

      instance
    end

    def max_candidates_will_change?(params:, instance:)
      params[:max_candidates] && params[:max_candidates] != instance.max_candidates
    end

    def model
      return ::InternshipOffers::Api if from_api?

      InternshipOffers::WeeklyFramed
    end

    def duplicate?(internship_offer)
      Array(internship_offer.errors.details[:remote_id])
        .map { |error| error[:error] }
        .include?(:taken)
    end
  end
end
