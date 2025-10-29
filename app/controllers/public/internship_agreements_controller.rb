module Public
  class InternshipAgreementsController < ApplicationController
    # No authentication required

    def upload
      @internship_agreement = find_internship_agreement

      return render_not_found unless @internship_agreement

      respond_to do |format|
        format.pdf do
          ext_file_name = @internship_agreement.internship_application
                                               .student
                                               .presenter
                                               .full_name_camel_case
          send_data(
            GenerateInternshipAgreement.new(@internship_agreement.id).call.render,
            filename: "Convention_de_stage_#{ext_file_name}.pdf",
            type: 'application/pdf',
            disposition: 'inline'
          )
        end
      end
    end

    def legal_representative_sign
      access_token = legal_representative_sign_internship_agreement_params[:access_token]
      @internship_agreement = InternshipAgreement.find_by(access_token: access_token)
      if @internship_agreement.nil?
        redirect_to root_path, alert: 'Convention introuvable' and return
      elsif @internship_agreement.signed_by_legal_representative? || access_token.nil?
        alert_msg = "Le représentant légal #{@internship_agreement.student_legal_representative_full_name} " \
                    "a déjà signé cette convention de stage"
        redirect_to root_path, alert: alert_msg and return
      else
        sign_in(@internship_agreement.student)
        authorize! :sign, @internship_agreement
        representative_full_name = representative_full_name(legal_representative_sign_internship_agreement_params[:student_legal_representative_nr])
        Signature.create!(internship_agreement: @internship_agreement,
                          signatory_role: 'student_legal_representative',
                          user_id: current_user.id,
                          student_legal_representative_full_name: representative_full_name,
                          signatory_ip: request.remote_ip,
                          signature_date: Time.now)

        @internship_agreement.sign! if @internship_agreement.may_sign?
        @internship_agreement.access_token = nil
        @internship_agreement.save
        sign_out(current_user)
        redirect_to new_dashboard_students_internship_agreement_path(uuid: @internship_agreement.uuid, student_id: @internship_agreement.student.id),
                    notice: 'Vous avez bien signé la convention de stage' and return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Convention introuvable' and return
    end

    private

    def legal_representative_sign_internship_agreement_params
      params.require(:signature)
            .permit(:uuid, :access_token, :student_id, :student_legal_representative_nr)
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
      # Use access_token for public access
      if params[:access_token].present?
        InternshipAgreement.find_by(access_token: params[:access_token])
      elsif params[:uuid].present?
        InternshipAgreement.find_by(uuid: params[:uuid])
      end
    end

    def legal_representative_sign_internship_agreement_params
      params.require(:signature)
            .permit(:uuid, :access_token, :student_id, :student_legal_representative_nr)
    end

    def render_not_found
      render file: "#{Rails.root}/public/404.html", status: :not_found
    end
  end
end