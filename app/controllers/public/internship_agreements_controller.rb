module Public
  class InternshipAgreementsController < ApplicationController
    layout 'no_link_layout', only: %i[show signed]

    def show
      @internship_agreement = find_internship_agreement
      return render_not_found unless @internship_agreement

      render :show
    end

    def signed
      @internship_agreement = InternshipAgreement.find_by(
        uuid: params[:uuid],
        aasm_state: %w[signatures_started signed]
      )
      return render_not_found unless @internship_agreement

      render :show
    end

    def upload
      @internship_agreement = find_internship_agreement

      return render_not_found unless @internship_agreement

      respond_to do |format|
        format.pdf do
          ext_file_name = @internship_agreement.internship_application
                                               .student
                                               .presenter
                                               .full_name_camel_case
          if params[:multi].present? && params[:multi] == 'true'
            send_data(
              GenerateMultiInternshipAgreement.new(@internship_agreement.uuid).call.render,
              filename: "Convention_de_stage_#{ext_file_name}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
            )
          else
            send_data(
              GenerateInternshipAgreement.new(@internship_agreement.id).call.render,
              filename: "Convention_de_stage_#{ext_file_name}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
            )
          end
        end
      end
    end


    def legal_representative_sign
      access_token = legal_representative_sign_internship_agreement_params[:access_token]
      @internship_agreement = find_by_access_token(access_token)

      if @internship_agreement.nil?
        redirect_to root_path, alert: 'Convention introuvable' and return
      elsif @internship_agreement.signed_by_legal_representative?
        alert_msg = "Le représentant légal #{@internship_agreement.student_legal_representative_full_name} " \
                    "a déjà signé cette convention de stage"
        redirect_to root_path, alert: alert_msg and return
      else
        representative_full_name = representative_full_name(legal_representative_sign_internship_agreement_params[:student_legal_representative_nr])
        Signature.create!(internship_agreement: @internship_agreement,
                          signatory_role: 'student_legal_representative',
                          user_id: @internship_agreement.student.id,
                          student_legal_representative_full_name: representative_full_name,
                          signatory_ip: request.remote_ip,
                          signature_date: Time.now)

        @internship_agreement.sign! if @internship_agreement.may_sign?
        @internship_agreement.update_columns(access_token: nil)
        redirect_to signed_public_internship_agreement_path(uuid: @internship_agreement.uuid) and return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Convention introuvable' and return
    end

    private

    def legal_representative_sign_internship_agreement_params
      params.expect(
        signature: [
          :uuid,
          :access_token,
          :student_id,
          :student_legal_representative_nr
        ]
      )
    end

    def representative_full_name(nr)
      if nr == '1'
        @internship_agreement.student_legal_representative_full_name
      elsif nr == '2'
        @internship_agreement.student_legal_representative_2_full_name
      else
        ''
      end
    end

    def find_internship_agreement
      record = find_by_access_token(params[:access_token])
      return nil unless record
      return nil if params[:uuid].present? && record.uuid.to_s != params[:uuid].to_s

      record
    end

    def find_by_access_token(token)
      return nil if token.blank?

      record = InternshipAgreement.find_by(access_token: token)
      return nil unless record
      return nil unless record.access_token.present? &&
                        record.access_token.bytesize == token.bytesize &&
                        ActiveSupport::SecurityUtils.secure_compare(record.access_token, token)

      record
    end

    def render_not_found
      head :not_found
    end
  end
end
