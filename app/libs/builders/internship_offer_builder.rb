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

    def update_from_stepper(internship_offer, user:, organisation:, internship_offer_info:, hosting_info:,
                            practical_info:)
      yield callback if block_given?
      authorize :update, model
      internship_offer.update(
        {}.merge(preprocess_organisation_to_params(organisation))
          .merge(preprocess_internship_offer_info_to_params(internship_offer_info))
          .merge(preprocess_hosting_info_to_params(hosting_info))
          .merge(preprocess_practical_info_to_params(practical_info))
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
      # preprocess_organisation(params)
      create_params = preprocess_api_params(params)
      internship_offer = model.create!(create_params)
      internship_offer.update(
        aasm_state: 'published',
        internship_offer_area_id: user.current_area_id
      )
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
      instance.attributes = preprocess_api_params(params)
      instance = deal_with_max_candidates_change(params: params, instance: instance)
      if from_api?
        instance.reset_publish_states
      elsif instance.may_publish? && instance.republish
        instance.publish!
      elsif instance.published_at.nil? && instance.may_unpublish?
        instance.unpublish!
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
        employer_id: internship_occupation.employer_id,
        internship_address_manual_enter: internship_occupation.internship_address_manual_enter
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
        entreprise_coordinates: entreprise.entreprise_coordinates
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
        internship_weeks_number: planning.weeks_count
      }
    end

    # def preprocess_organisation_to_params(organisation)
    #   {
    #     employer_name: organisation.employer_name,
    #     employer_website: organisation.employer_website,
    #     employer_description: organisation.employer_description,
    #     is_public: organisation.is_public,
    #     siret: organisation.siret,
    #     employer_manual_enter: organisation.manual_enter,
    #     group_id: organisation.group_id
    #   }
    # end

    # def preprocess_internship_offer_info_to_params(internship_offer_info)
    #   {
    #     sector_id: internship_offer_info.sector_id,
    #     title: internship_offer_info.title,
    #     description: internship_offer_info.description,
    #     type: 'InternshipOfferInfo'
    #   }
    # end

    # def preprocess_hosting_info_to_params(hosting_info)
    #   {
    #     max_candidates: hosting_info.max_candidates,
    #     type: 'InternshipOffers::WeeklyFramed',
    #     period: hosting_info.period,
    #     school_id: hosting_info.school_id
    #   }
    # end

    # def preprocess_practical_info_to_params(practical_info)
    #   {
    #     weekly_hours: practical_info.weekly_hours,
    #     daily_hours: practical_info.daily_hours,
    #     lunch_break: practical_info.lunch_break,
    #     street: practical_info.street,
    #     zipcode: practical_info.zipcode,
    #     city: practical_info.city,
    #     coordinates: practical_info.coordinates,
    #     contact_phone: practical_info.contact_phone,
    #   }
    # end

    # def preprocess_organisation(params)
    #   return params unless params['organisation_attributes']

    #   orga_params = params['organisation_attributes']
    #   params['employer_name'] = orga_params['employer_name'] unless orga_params['employer_name'].blank?
    #   params['employer_website'] = orga_params['employer_website'] unless orga_params['employer_website'].blank?
    #   params['coordinates'] = orga_params['coordinates'] unless orga_params['coordinates'].blank?
    #   params['street'] = orga_params['street'] unless orga_params['street'].blank?
    #   params['zipcode'] = orga_params['zipcode'] unless orga_params['zipcode'].blank?
    #   params['city'] = orga_params['city'] unless orga_params['city'].blank?
    #   params['is_public'] = orga_params['is_public'] unless orga_params['is_public'].blank?
    #   params['group_id'] = orga_params['group_id'] unless orga_params['group_id'].blank?
    # end

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
