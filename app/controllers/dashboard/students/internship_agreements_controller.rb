module Dashboard::Students
  class InternshipAgreementsController < ApplicationController
    include EduconnectLogout
    layout 'student_legal_representative_layout', only: %i[new]
    before_action :authenticate_user!, only: %i[sign legal_representative_sign]
    before_action :fetch_internship_agreement

    def new
      access_token = params[:access_token]
      internship_agreement = InternshipAgreement.find_by(access_token: access_token)
      redirect_to root_path and return if internship_agreement.nil?

      render :new, params: { 
        student_id: internship_agreement.student.id ,
        uuid: params[:uuid],
        access_token: access_token
      }
    end

    def sign
      authorize! :sign, @internship_agreement
      Signature.create!(internship_agreement: @internship_agreement,
                        signatory_role: 'student',
                        user_id: current_user.id,
                        signatory_ip: request.remote_ip,
                        signature_date: Time.now)

      @internship_agreement.sign! if @internship_agreement.may_sign?
      redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                  notice: 'Vous avez bien signé la convention de stage'
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                  alert: 'Convention introuvable'
    end

    def legal_representative_sign
      access_token = legal_representative_sign_internship_agreement_params[:access_token]
      @internship_agreement = InternshipAgreement.find_by(access_token: access_token)
      # student = internship_agreement.student
      redirect_to root_path and return unless @internship_agreement.present?

      if @internship_agreement.signed_by_legal_representative?
        redirect_to root_path, alert: 'Un représentant légal a déjà signé cette convention de stage' and return
      else
        Signature.create!(internship_agreement: @internship_agreement,
                          signatory_role: 'student_legal_representative',
                          user_id: current_user.id,
                          student_legal_representative_full_name: legal_representative_sign_internship_agreement_params[:student_legal_representative_full_name],
                          signatory_ip: request.remote_ip,
                          signature_date: Time.now)

        @internship_agreement.sign! if @internship_agreement.may_sign?
        @internship_agreement.access_token = nil
        @internship_agreement.save
        redirect_to root_path, notice: 'Vous avez bien signé la convention de stage' and return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Convention introuvable' and return
    end

    private

    def legal_representative_sign_internship_agreement_params
      params.require(:signature)
            .permit(:uuid, :access_token, :student_id, :student_legal_representative_full_name)
    end

    def fetch_internship_agreement
      @internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
    end
  end
end
