module Dashboard::Students
  class InternshipAgreementsController < ApplicationController
    def sign
      @internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
      authorize! :sign, @internship_agreement
      Signature.create!(internship_agreement: @internship_agreement,
                        signatory_role: 'student',
                        user_id: current_user.id,
                        signatory_ip: request.remote_ip,
                        signature_date: Time.now)

      @internship_agreement.sign! if @internship_agreement.may_sign?
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                  alert: 'Convention introuvable'
    else
      redirect_to dashboard_students_internship_applications_path(student_id: current_user.id),
                  notice: 'Vous avez bien signé la convention de stage'
    end
  end
end
