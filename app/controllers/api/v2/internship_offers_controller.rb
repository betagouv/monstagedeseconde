# frozen_string_literal: true

module Api
  module V2
    class InternshipOffersController < Api::Shared::InternshipOffersController
      include Api::AuthV2

      def search
        render_not_authorized and return unless current_api_user.operator.api_full_access

        params[:week_ids] = serialize_week_ids(params[:weeks]) if params[:weeks]
        params[:sector_ids] = serialize_sector_ids(params[:sectors]) if params[:sectors]
        params[:grades] = serialize_grades(params[:grades]) if params[:grades]

        @internship_offers = finder.all.includes(%i[sector internship_offer_weeks]).order(id: :desc)
        if @current_api_user.operator.departments.any?
          @internship_offers = @internship_offers.by_department(@current_api_user.operator.departments.map(&:name))
        end

        formatted_internship_offers = format_internship_offers(@internship_offers)
        data = {
          pagination: page_links,
          internshipOffers: formatted_internship_offers
        }
        render json: data, status: 200
      end

      def create
        check_params_validity
        return if performed?

        serialize_params

        internship_offer_builder.create(params: create_internship_offer_params) do |on|
          on.success(&method(:render_created))
          on.failure(&method(:render_validation_error))
          on.duplicate(&method(:render_duplicate))
          on.argument_error(&method(:render_argument_error))
        end
      end

      def update
        if params[:internship_offer] && params[:internship_offer][:weeks]
          params[:internship_offer][:week_ids] =
            serialize_week_ids(params[:internship_offer][:weeks])
        end

        internship_offer_builder.update(instance: InternshipOffer.find_by!(remote_id: params[:id]),
                                        params: update_internship_offer_params) do |on|
          on.success(&method(:render_ok))
          on.failure(&method(:render_validation_error))
          on.argument_error(&method(:render_argument_error))
        end
      end

      private

      def create_internship_offer_params
        params.require(:internship_offer)
              .permit(
                :title,
                :description,
                :employer_name,
                :employer_chosen_name,
                :employer_description,
                :employer_website,
                :street,
                :zipcode,
                :city,
                :remote_id,
                :permalink,
                :sector_uuid,
                :type,
                :max_candidates,
                :is_public,
                :period,
                :handicap_accessible,
                :lunch_break,
                grades: [],
                week_ids: [],
                daily_hours: {},
                coordinates: {}
              )
      end

      def update_internship_offer_params
        params.require(:internship_offer)
              .permit(
                :title,
                :description,
                :employer_name,
                :employer_chosen_name,
                :employer_description,
                :employer_website,
                :street,
                :zipcode,
                :city,
                :permalink,
                :sector_uuid,
                :max_candidates,
                :published_at,
                :is_public,
                :period,
                :lunch_break,
                :handicap_accessible,
                grades: [],
                week_ids: [],
                daily_hours: {},
                coordinates: {}
              )
      end

      def query_params
        params.permit(
          :page,
          :latitude,
          :longitude,
          :radius,
          :keyword,
          sector_ids: [],
          week_ids: []
        )
      end

      def format_internship_offers(internship_offers)
        internship_offers.map do |internship_offer|
          {
            id: internship_offer.id,
            title: internship_offer.title,
            description: internship_offer.description.to_s,
            employer_name: internship_offer.employer_name,
            url: internship_offer_url(internship_offer,
                                      query_params.merge({ utm_source: current_api_user.operator.name })),
            city: internship_offer.city.capitalize,
            date_start: I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy),
            date_end: I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy),
            latitude: internship_offer.coordinates.latitude,
            longitude: internship_offer.coordinates.longitude,
            image: view_context.asset_pack_url("media/images/sectors/#{internship_offer.sector.cover}"),
            sector: internship_offer.sector.name,
            handicap_accessible: internship_offer.handicap_accessible,
            period: internship_offer.period,
            weeks: internship_offer.weeks_api_formatted
          }
        end
      end

      def serialize_sector_ids(sectors)
        sectors.map { |sector_uuid| Sector.find_by(uuid: sector_uuid).id }
      end

      def serialize_week_ids(weeks)
        weeks.map do |iso_week|
          year = iso_week.split('-').first
          week_number = iso_week.split('-').second.delete('W')
          Week.find_by(year: year, number: week_number)&.id
        end.compact
      end

      def serialize_params
        return unless params[:internship_offer][:weeks]

        params[:internship_offer][:week_ids] =
          serialize_week_ids(params[:internship_offer][:weeks])
      end

      def check_params_validity
        check_presence_of_params
        check_grades_and_weeks_validity
      end

      def check_grades_and_weeks_validity
        MANDATORY_SECONDE_WEEKS = SchoolTrack::Seconde.both_weeks.map do |week|
          "#{week.year}-W#{week.number.to_s.rjust(2, '0')}"
        end.freeze

        is_seconde = params[:internship_offer][:grades].include?('seconde')
        has_mandatory_weeks = MANDATORY_SECONDE_WEEKS.any? { |week| params[:internship_offer][:weeks].include?(week) }

        return unless is_seconde && !has_mandatory_weeks

        render_error(code: 'WRONG_PARAMS', error: 'wrong weeks for seconde grade', status: :unprocessable_entity)
      end

      def check_presence_of_params
        required_params = %i[
          grades
          weeks
        ]

        raise ActionController::ParameterMissing, :internship_offer unless params[:internship_offer]

        required_params.each do |param|
          raise ActionController::ParameterMissing, param unless params[:internship_offer][param]
        end
      end
    end
  end
end
