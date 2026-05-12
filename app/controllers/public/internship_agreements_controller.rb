module Public
  class InternshipAgreementsController < ApplicationController
    # Public access is gated by one of:
    #   1. a valid access_token (single-use, emailed to the legal representative)
    #   2. a signed-in user with CanCanCan permission on the agreement
    #   3. a session marker set right after a successful legal-representative signature
    # The agreement UUID alone never grants access.
    layout 'no_link_layout', only: %i[show]

    def show
      @internship_agreement = find_internship_agreement
      if @internship_agreement.nil?
        redirect_to root_path, alert: 'Convention introuvable' and return
      end

      mark_session_access(@internship_agreement) if params[:access_token].present?
    end

    def upload
      @internship_agreement = find_internship_agreement
      if @internship_agreement.nil?
        redirect_to root_path, alert: 'Convention introuvable' and return
      end

      mark_session_access(@internship_agreement) if params[:access_token].present?

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
      submitted_token = legal_representative_sign_internship_agreement_params[:access_token].to_s
      @internship_agreement = find_by_access_token(submitted_token)

      if @internship_agreement.nil?
        redirect_to root_path, alert: 'Convention introuvable' and return
      end

      if @internship_agreement.signed_by_legal_representative?
        alert_msg = "Le représentant légal #{@internship_agreement.student_legal_representative_full_name} " \
                    "a déjà signé cette convention de stage"
        redirect_to root_path, alert: alert_msg and return
      end

      unless @internship_agreement.may_sign?
        redirect_to root_path, alert: 'Cette convention ne peut pas être signée pour le moment' and return
      end

      representative_full_name = representative_full_name(
        legal_representative_sign_internship_agreement_params[:student_legal_representative_nr]
      )

      Signature.create!(internship_agreement: @internship_agreement,
                        signatory_role: 'student_legal_representative',
                        user_id: @internship_agreement.student.id,
                        student_legal_representative_full_name: representative_full_name,
                        signatory_ip: request.remote_ip,
                        signature_date: Time.now)

      @internship_agreement.sign! if @internship_agreement.may_sign?
      @internship_agreement.update(access_token: nil)

      mark_session_access(@internship_agreement)

      redirect_to public_internship_agreement_path(uuid: @internship_agreement.uuid),
                  notice: 'Vous avez bien signé la convention de stage'
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Convention introuvable'
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
      submitted_token = params[:access_token].to_s
      return find_by_access_token(submitted_token) if submitted_token.present?
      return nil if params[:uuid].blank?

      agreement = InternshipAgreement.find_by(uuid: params[:uuid])
      return nil if agreement.nil?
      return agreement if session_authorized?(agreement)
      return agreement if user_authorized?(agreement)

      nil
    end

    def find_by_access_token(submitted_token)
      return nil if submitted_token.blank?

      InternshipAgreement.find_by(access_token: submitted_token)
    end

    def session_authorized?(agreement)
      Array(session[:signed_agreement_ids]).include?(agreement.id)
    end

    def user_authorized?(agreement)
      return false unless user_signed_in?

      current_ability.can?(:show, agreement)
    end

    def mark_session_access(agreement)
      ids = Array(session[:signed_agreement_ids])
      ids << agreement.id
      session[:signed_agreement_ids] = ids.uniq.last(20)
    end
  end
end
