# frozen_string_literal: true

module Dto
  # adapt api params to model
  class ApiParamsAdapter
    def sanitize
      check_street
      check_zipcode
      check_coordinates
      check_grades
      map_sector_uuid_to_sector
      assign_offer_to_current_api_user
      check_fields_size
      params
    end

    private

    attr_reader :params, :user

    def initialize(params:, user:)
      @params = params
      @user = user
    end

    def map_sector_uuid_to_sector
      return params unless params.key?(:sector_uuid)

      params[:sector] = Sector.where(uuid: params.delete(:sector_uuid)).first
      params
    end

    def assign_offer_to_current_api_user
      params[:employer] = user
      params
    end

    def check_street
      if params[:street].blank? && params[:coordinates].present?
        params[:street] = Geofinder.street(params[:coordinates]['latitude'], params[:coordinates]['longitude']) || 'N/A'
      end
      params
    end

    def check_zipcode
      if params[:zipcode].blank? && params[:coordinates].present?
        params[:zipcode] =
          Geofinder.zipcode(params[:coordinates]['latitude'], params[:coordinates]['longitude']) || 'N/A'
      end
      params
    end

    def check_coordinates
      if params[:coordinates].blank? && params[:zipcode].present?
        coordinates = Geofinder.coordinates("#{params[:zipcode]}, France")
        params[:coordinates] = { 'latitude' => coordinates[0], 'longitude' => coordinates[1] } unless coordinates.empty?
      end
      params
    end

    def shrink_factory(field, size)
      field = field.to_sym unless field.is_a? Symbol
      params[field] = params[field].truncate(size) if params[field].present?
    end

    def shrink_fields_size
      shrink_factory(:title, 150)
      shrink_factory(:description, 1500)
      shrink_factory(:street, 500)
      shrink_factory(:zipcode, 5)
      shrink_factory(:city, 50)
      shrink_factory(:department, 40)
      shrink_factory(:contact_phone, 20)
      shrink_factory(:employer_name, 150)
      shrink_factory(:employer_chosen_name, 150)
      shrink_factory(:entreprise_full_address, 200)
    end

    def check_grades
      params[:grades] = if params[:grades]
                          params[:grades].map { |grade| Grade.find_by(short_name: grade) }
                        else
                          [Grade.seconde] # api v1 default grade
                        end
      params
    end
  end
end
