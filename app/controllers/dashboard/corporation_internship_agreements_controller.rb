module Dashboard
  class CorporationInternshipAgreementsController < ApplicationController
    layout 'no_link_layout'

    def index
      @corporation_sgid = index_corporation_internship_agreement_params[:corporation_sgid]
      @corporation = fetch_corporation_from_sgid
      return head :not_found unless @corporation.present?

      corporation_internship_agreements = CorporationInternshipAgreement.joins(:internship_agreement)
                                                                        .where(corporation_id: @corporation.id)
                                                                        .where(internship_agreement: { aasm_state: InternshipAgreement::TO_BE_SIGNED_STATES })
      @internship_agreements = corporation_internship_agreements.map(&:internship_agreement)
                                                                .select { |ia| ia.pre_selected_for_signature? }

      @internship_agreement_uuids = @internship_agreements.map(&:uuid) #corporation_internship_agreement_params[:internship_agreement_uuids].to_a
      @coporation_prez = @corporation.presenter
      @to_be_signed_metadata = { count: corporation_internship_agreements.where(signed: false).count }
      @conventions_text = conventions_text(corporation_internship_agreements.where(signed: false).count)
    end

    def multi_sign
      @corporation_sgid = corporation_internship_agreement_params[:corporation_sgid]
      @corporation = fetch_corporation_from_sgid
      return head :not_found unless @corporation.present?

      sanitize(params[:corporation_internship_agreement][:internship_agreement_uuids])

      if @internship_agreement_uuids.empty?
        internship_agreements = @corporation.internship_agreements
        @internship_agreement_uuids = internship_agreements.map(&:uuid)
        notice = "Aucune convention n'a été sélectionnée."
      else
        internship_agreements = InternshipAgreement.where(uuid: @internship_agreement_uuids)
                                                   .where(aasm_state: InternshipAgreement::TO_BE_SIGNED_STATES)
        corporation_internship_agreements = CorporationInternshipAgreement.where(
          corporation_id: @corporation.id,
          internship_agreement_id: internship_agreements.pluck(:id)
        )
        CorporationInternshipAgreement.transaction do
          corporation_internship_agreements.each do |cia|
            cia.update!(signed: true, signed_at: Time.current)
          end
        end
        notice = 'Les conventions ont été mises à jour avec succès.'
      end
      target_path = dashboard_corporation_internship_agreements_path(
        corporation_sgid: @corporation_sgid,
        internship_agreement_uuids: @internship_agreement_uuids
        )
      redirect_to target_path, notice: notice

    rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
      @internship_agreements = InternshipAgreement.where(uuid: @internship_agreement_uuids)
      render :index, status: :unprocessable_entity
    end

    private

    def index_corporation_internship_agreement_params
      params.permit(:corporation_sgid)
    end

    def corporation_internship_agreement_params
      params.expect(corporation_internship_agreement: [
              :corporation_sgid,
              :signed,
              ids: [],
              internship_agreement_uuids: []
      ])
    end

    def fetch_corporation_from_sgid
      GlobalID::Locator.locate_signed(@corporation_sgid )
    end

    def sanitize(uuids_param)
      puts uuids_param
      sanitized_uuids = if uuids_param.is_a?(Array)
                          uuids_param.reject(&:blank?)
                        elsif uuids_param.is_a?(String)
                          uuids_param.split(' ')
                        else
                          []
                        end

      internship_agreements = InternshipAgreement.where(uuid: sanitized_uuids)
                                                 .where(aasm_state: InternshipAgreement::TO_BE_SIGNED_STATES)
      @internship_agreement_uuids = internship_agreements.map(&:uuid) # to reflect only valid ones
    end

    def conventions_text(count)
      case count
      when 0
        "n'avez aucune convention de stage"
      when 1
        'avez une convention de stage'
      else
        "avez #{count} conventions de stage"
      end
    end

  end
end
