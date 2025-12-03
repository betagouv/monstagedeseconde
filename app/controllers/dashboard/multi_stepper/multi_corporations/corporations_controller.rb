module Dashboard::MultiStepper
  module MultiCorporations
    class CorporationsController < ApplicationController
      before_action :authenticate_user!
      before_action :fetch_multi_corporation
      before_action :fetch_corporation, only: %i[edit update destroy]

      def create
        @corporation = @multi_corporation.corporations.build(corporation_params)
        authorize! :create, @corporation

        if @corporation.save
          respond_to do |format|
            format.turbo_stream
            format.html { redirect_to edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation), notice: 'Structure ajoutée' }
          end
        else
          render :new, status: :bad_request
        end
      end

      def edit
        authorize! :update, @corporation
        respond_to do |format|
          format.turbo_stream
        end
      end

      def update
        authorize! :update, @corporation
        if @corporation.update(corporation_params)
          respond_to do |format|
            format.turbo_stream
            format.html { redirect_to edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation), notice: 'Structure mise à jour' }
          end
        else
          render :edit, status: :bad_request
        end
      end

      def destroy
        authorize! :destroy, @corporation
        @corporation.destroy
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation), notice: 'Structure supprimée' }
        end
      end

      private

      def fetch_multi_corporation
        @multi_corporation = MultiCorporation.find(params[:multi_corporation_id])
      end

      def fetch_corporation
        @corporation = @multi_corporation.corporations.find(params[:id])
      end

      def corporation_params
        params.require(:corporation).permit(
          :siret, :sector_id, :employer_name, :employer_address, :phone,
          :internship_street, :internship_zipcode, :internship_city, :internship_phone,
          :city, :zipcode, :street,
          :tutor_name, :tutor_role_in_company, :tutor_email, :tutor_phone
        )
      end
    end
  end
end
