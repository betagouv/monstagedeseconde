module Dashboard::MultiStepper
  module MultiCorporations
    class CorporationsController < ApplicationController
      before_action :authenticate_user!
      before_action :fetch_multi_corporation
      before_action :fetch_corporation, only: %i[edit update destroy]

      def create
        puts "🔹 [CorporationsController] START create"
        puts "🔹 [CorporationsController] Params received: #{params.inspect}"
        puts "🔹 [CorporationsController] Corporation params: #{corporation_params.inspect}"
        process_corporation_params
        @corporation = @multi_corporation.corporations.build(corporation_params)
        authorize! :create, @corporation
        
        puts "🔹 [CorporationsController] Corporation built: #{@corporation.inspect}"
        puts "🔹 [CorporationsController] Valid? #{@corporation.valid?}"

        if @corporation.save
          puts "✅ [CorporationsController] Corporation saved successfully"
          respond_to do |format|
            format.turbo_stream
            format.html { redirect_to new_dashboard_multi_stepper_multi_corporation_path(multi_coordinator_id: @multi_corporation.multi_coordinator_id), notice: 'Structure ajoutée' }
          end
        else
          puts "❌ [CorporationsController] Corporation save FAILED"
          puts "❌ [CorporationsController] Errors: #{@corporation.errors.full_messages}"
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

      def process_corporation_params
        params[:corporation][:internship_street] = params[:corporation][:street]
        params[:corporation][:internship_zipcode] = params[:corporation][:zipcode]
        params[:corporation][:internship_city] = params[:corporation][:city]
      end

      def corporation_params
        params.require(:corporation).permit(
          :siret, :sector_id, 
          :corporation_name, :corporation_address, :corporation_city, :corporation_zipcode, :corporation_street,
          :internship_street, :internship_zipcode, :internship_city, :internship_phone,
          :tutor_name, :tutor_role_in_company, :tutor_email, :tutor_phone,
          :employer_name, :employer_role, :employer_email, :employer_phone
        )
      end
    end
  end
end
