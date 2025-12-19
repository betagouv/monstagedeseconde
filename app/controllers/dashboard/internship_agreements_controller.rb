module Dashboard
  class InternshipAgreementsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_internship_agreement,
                  only: %i[edit update show school_management_signature school_management_sign]

    def new
      @internship_agreement = internship_agreement_builder.new_from_application(
        InternshipApplication.find_by(uuid: params[:internship_application_uuid])
      )
    end

    def edit
      authorize! :update, @internship_agreement
    end

    def update
      authorize! :update, @internship_agreement
      internship_agreement_builder.update(instance: @internship_agreement,
                                          params: internship_agreement_params) do |on|
        on.success do |updated_internship_agreement|
          updated_internship_agreement = process_state_update(
            agreement: updated_internship_agreement,
            params:
          )
          updated_internship_agreement.save
          redirect_to dashboard_internship_agreements_path(multi: updated_internship_agreement.from_multi?),
                      flash: { success: update_success_message(updated_internship_agreement) }
        end
        on.failure do |failed_internship_agreement|
          @internship_agreement = failed_internship_agreement || InternshipAgreement.find_by(uuid: params[:uuid])
          render :edit
        end
      end
    rescue ActionController::ParameterMissing => e
      @internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
      render :edit
    end

    def show
      authorize! :show, @internship_agreement
      respond_to do |format|
        format.html
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

    def index
      authorize! :index, InternshipAgreement
      if current_user.employer_like?
        @internship_offers = current_user.internship_offers
                                         .includes([:weeks, { school: :school_managers }])
      end
      @mono_internship_agreements  = filtering_query current_user.mono_internship_agreements
      @multi_internship_agreements = filtering_query current_user.multi_internship_agreements

      @school = current_user.school if current_user.school_management?
      @no_agreement_internship_application_list = []
    end

    def school_management_signature
      authorize! :sign_internship_agreements, @internship_agreement
    end

    def school_management_sign
      authorize! :sign_internship_agreements, @internship_agreement
      if params.dig(
        :internship_agreement, :signature
      ).blank? && @internship_agreement.school.signature.blank?
        redirect_to dashboard_internship_agreements_path,
                    flash: { danger: 'Vous devez d\'abord importer la signature du chef d\'établissement. Avant de signer la convention.' } and return
      end

      update_school_signature if params.dig(:internship_agreement, :signature).present?

      Signature.create!(internship_agreement: @internship_agreement,
                        signatory_role: current_user.role,
                        user_id: current_user.id,
                        signatory_ip: request.remote_ip,
                        signature_date: Time.now,
                        signature_phone_number: current_user.try(:phone))
      @internship_agreement.sign!

      redirect_to dashboard_internship_agreements_path(multi: @internship_agreement.from_multi?),
                  flash: { success: 'La convention a été signée.' }
    end

    private

    def fields
      [:internship_application_id,
              :student_school,
              :school_representative_email,
              :school_representative_full_name,
              :school_representative_function,
              :school_representative_phone,
              :school_representative_role,
              :delegation_date,
              :legal_status,
              :student_full_name,
              :student_class_room,
              :date_range,
              :activity_scope,
              :legal_terms_rich_text,
              :organisation_representative_full_name,
              :organisation_representative_role,
              :employer_event,
              :employer_name,
              :internship_address,
              :employer_contact_email,
              :school_manager_event,
              :student_refering_teacher_full_name,
              :student_refering_teacher_email,
              :student_refering_teacher_phone,
              :student_address,
              :student_phone,
              :student_legal_representative_full_name,
              :student_legal_representative_email,
              :student_legal_representative_phone,
              :student_legal_representative_2_full_name,
              :student_legal_representative_2_email,
              :student_legal_representative_2_phone,
              :siret,
              :student_birth_date,
              :pai_project,
              :pai_trousse_family,
              :tutor_full_name,
              :tutor_role,
              :entreprise_address,
              :lunch_break,
              :weekly_lunch_break,
              weekly_hours: [],
              daily_hours: {}]
    end

    def internship_agreement_params
      requirement = if @internship_agreement.from_multi?
                      :internship_agreements_multi_internship_agreement
                    else
                      :internship_agreements_mono_internship_agreement
                    end
      params.require(requirement).permit(*fields)
    end

    def bare_internship_agreement_params
      params.require(:internship_agreement).permit(*fields)
    end

    def filtering_query(query)
      query.filtering_discarded_students
           .kept
           .includes(
             { internship_application: [
               { student: :school },
               { internship_offer: [:employer, :sector, :stats, :weeks,
                                   { school: :school_managers }] }
             ] }
           )
    end

    def internship_agreement_builder
      @builder ||= Builders::InternshipAgreementBuilder.new(user: current_user)
    end

    def update_success_message(internship_agreement)
      case internship_agreement.aasm_state
      when 'started_by_employer' then 'La convention a été enregistrée.'
      when 'completed_by_employer' then "La convention a été envoyée au chef d'établissement."
      when 'started_by_school_manager' then 'La convention a été enregistrée.'
      when 'validated' then "La convention est validée, le fichier pdf de la convention est maintenant disponible. Un mail a été envoyé à l'offreur, à l'élève et à ses responsables légaux."
      else
        'La convention a été enregistrée.'
      end
    end

    def process_state_update(agreement:, params:)
      params_internship_agreement = agreement.from_multi? ? params[:internship_agreements_multi_internship_agreement] : params[:internship_agreements_mono_internship_agreement]

      employer_event       = params_internship_agreement[:employer_event]
      school_manager_event = params_internship_agreement[:school_manager_event]
      return agreement if employer_event.blank? && school_manager_event.blank?

      agreement = transit_when_allowed(agreement:, event: employer_event)
      transit_when_allowed(agreement:, event: school_manager_event)
    end

    def transit_when_allowed(agreement:, event:)
      return agreement if event.blank?
      return agreement unless agreement.send("may_#{event}?")

      agreement.send(event)
      agreement
    end

    def set_internship_agreement
      @internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
      unless @internship_agreement.nil?
        @mono_internship_agreement = @internship_agreement.from_multi? ? nil : @internship_agreement
        @multi_internship_agreement = @internship_agreement.from_multi? ? @internship_agreement : nil
      end
    end

    def update_school_signature
      @internship_agreement.student.school.signature = params[:internship_agreement][:signature]
      @internship_agreement.student.school.save
    end
  end
end
