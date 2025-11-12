module Dashboard::Students
  class InternshipAgreementsController < ApplicationController
    include EduconnectLogout
    layout 'no_link_layout', only: %i[new]
    before_action :authenticate_user!, only: %i[sign]
    before_action :fetch_internship_agreement

    def new
      #anyone can access this page and layout
      # but only with a valid access_token and if not already signed by legal representative
      access_token = params[:access_token]
      student_legal_representative_nr = params[:student_legal_representative_nr]
      if @internship_agreement.signed_by_legal_representative?
        render :new,
               params: {
                 student_id: @internship_agreement.student.id,
                 uuid: params[:uuid]
               } and return
      end
      # verification through access_token
      @internship_agreement = InternshipAgreement.find_by(access_token: access_token)
      if @internship_agreement.nil?
        redirect_to root_path, alert: "Convention introuvable" and return
      end
      render :new, params: {
        student_id: @internship_agreement.student.id ,
        uuid: params[:uuid],
        access_token: access_token,
        student_legal_representative_nr: student_legal_representative_nr
      }
    end

    def sign
      authorize! :sign, @internship_agreement
      if @internship_agreement.signed_by_student?
        redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                  alert: 'Vous avez déjà signé cette convention de stage' and return
      end
      if @internship_agreement.may_sign? && current_user.student?
        Signature.create!(internship_agreement: @internship_agreement,
                          signatory_role: 'student',
                          user_id: current_user.id,
                          signatory_ip: request.remote_ip,
                          signature_date: Time.now)
        @internship_agreement.sign!
        redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                    notice: 'Vous avez bien signé la convention de stage. Un email a été envoyé aux responsables légaux pour les inviter à signer la convention de stage.' and return
      else
        redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                    notice: 'La signature de la convention de stage n\'a pas pu être effectuée.' and return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                  alert: 'Convention introuvable'
    end


    private


    def fetch_internship_agreement
      @internship_agreement ||= InternshipAgreement.find_by(uuid: params[:uuid])
    end
  end
end
