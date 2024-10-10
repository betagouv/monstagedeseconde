module Dashboard::Stepper
  class EntreprisesController < ApplicationController
    # step 2
    before_action :authenticate_user!

    def new
      @entreprise = Entreprise.new(internship_occupation_id: params[:internship_occupation_id])
    end

    def create
    end

    def edit
    end

    def update
    end

    private

    def clean_params
    end

    def entreprise_params
      params.require(:entreprise)
            .permit(
              :manual_enter,
              :siret,
              :is_public,
              :employer_name,
              :chosen_employer_name,
              :entreprise_city,
              :entreprise_zipcode,
              :entreprise_street,
              :entreprise_coordinates,
              :tutor_first_name,
              :tutor_last_name,
              :tutor_email,
              :tutor_phone,
              :tutor_function,
              :group_id
            )
    end

    def entreprise_params
    end

    # def fetch_internship_occupation
    #   @internship_occupation = InternshipOccupation.find(params[:internship_occupation_id])
    # end
  end
end
