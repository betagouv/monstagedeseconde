module Dashboard
  class CorporationInternshipAgreementsController < ApplicationController
    layout 'no_link_layout'

    def index
      @corporation_sgid = index_corporation_internship_agreement_params[:corporation_sgid]
      @corporation = fetch_corporation_from_sgid
      return head :not_found unless @corporation.present?

      corporation_internship_agreements = CorporationInternshipAgreement.where(corporation_id: @corporation.id)
      @internship_agreement_uuids = corporation_internship_agreements.map(&:internship_agreement).map(&:uuid) #corporation_internship_agreement_params[:internship_agreement_uuids].to_a

      @coporation_prez = @corporation.presenter
      @internship_agreements = InternshipAgreement.where(uuid: @internship_agreement_uuids)

      @to_be_signed_metadata = {
        count: corporation_internship_agreements.where(signed: false).count,
      }
    end

    # ok for one at a time
    def update
      @corporation_sgid = corporation_internship_agreement_params[:corporation_sgid]
      @corporation = fetch_corporation_from_sgid
      return head :not_found unless @corporation.present?

      @internship_agreement_uuid = corporation_internship_agreement_params[:internship_agreement_uuid]
      internship_agreement = InternshipAgreement.find_by(uuid: @internship_agreement_uuid)
      # @internship_agreement_uuids = corporation_internship_agreement_params[:internship_agreement_uuids]
      # if @internship_agreement_uuids.is_a?(Array)
      #   @internship_agreement_uuids = @internship_agreement_uuids.reject(&:blank?)
      # elsif @internship_agreement_uuids.is_a?(String)
      #   @internship_agreement_uuids = [@internship_agreement_uuids]
      # else
      #   @internship_agreement_uuids = []
      # end
      signed = corporation_internship_agreement_params[:signed] == '1'

      corporation_intership_agreement = CorporationInternshipAgreement.find_by(
          corporation_id: @corporation.id,
          internship_agreement_id: internship_agreement.id
      )

      if corporation_intership_agreement && corporation_intership_agreement.update(signed: signed)
        target_path =  dashboard_corporation_internship_agreements_path(
          corporation_sgid: @corporation_sgid,
          )
        redirect_to target_path,
                    notice: 'La convention a été mise à jour avec succès.'
      else
        @internship_agreements = InternshipAgreement.where(uuid: @internship_agreement_uuids)
        render :index, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render :index, status: :unprocessable_entity
    end

    private

    def index_corporation_internship_agreement_params
      params.permit(:corporation_sgid, internship_agreement_uuids: [])
    end

    def corporation_internship_agreement_params
      params.require(:corporation_internship_agreement)
            .permit(
              :corporation_sgid,
              :internship_agreement_uuid,
              :signed,
              :internship_agreement_uuids => [])
    end

    def fetch_corporation_from_sgid
      GlobalID::Locator.locate_signed(@corporation_sgid )
    end
  end
end
