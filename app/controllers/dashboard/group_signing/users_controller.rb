module Dashboard
  module GroupSigning
    class UsersController < ApplicationController
      include Phonable

      def start_signing
        # javascript opens the right modal according to
        # current_user phone number existence
        authorize! :sign_internship_agreements, InternshipAgreement
        @internship_agreement_ids = user_params[:internship_agreement_ids] || []
        @counter = @internship_agreement_ids.size
        @agreement_ids = @internship_agreement_ids.join(',')
        current_user.send_signature_sms_token if current_user.formatted_phone.present?
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream:
              turbo_stream.update('internship-agreement-group',
                                  partial: starting_path(current_user),
                                  locals: { agreement_ids: @agreement_ids,
                                            counter: @counter })
          end
        end
      end

      def update
        authorize! :sign_internship_agreements, InternshipAgreement
        @agreement_ids = user_params[:agreement_ids]
        if current_user.save_phone_user(user_params) &&
           current_user.reload.send_signature_sms_token
          respond_to do |format|
            format.turbo_stream do
              path = 'dashboard/internship_agreements/signature/modal_code_submit'
              render turbo_stream:
                turbo_stream.replace('internship-agreement-signature-form',
                                     partial: path,
                                     locals: { current_user:,
                                               agreement_ids: @agreement_ids })
            end
          end
        elsif current_user.errors.any?
          respond_to do |format|
            format.turbo_stream do
              err_path = 'dashboard/internship_agreements/signature/code_error_messages'
              err_msg = current_user.errors.messages.values.flatten.join(',')
              render turbo_stream:
                turbo_stream.replace('update-error-messages',
                                     partial: err_path,
                                     locals: { error_message: err_msg,
                                               agreement_ids: @agreement_ids })
            end
          end
        else
          redirect_to dashboard_internship_agreements_path,
                      alert: "Une erreur est survenue et le SMS n'a pas été envoyé"
        end
      end

      def reset_phone_number
        # opened_modal will wake up either the phone_number_modal or the code typing one
        authorize! :sign_internship_agreements, InternshipAgreement
        if current_user.nullify_phone_number!
          redirect_to dashboard_internship_agreements_path(opened_modal: true),
                      notice: 'Votre numéro de téléphone a été supprimé'
        else
          redirect_to dashboard_internship_agreements_path,
                      alert: 'Une erreur est survenue et ' \
                             "votre demande n'a pas été traitée"
        end
      end

      def resend_sms_code
        authorize! :sign_internship_agreements, InternshipAgreement
        @agreement_ids = user_params[:agreement_ids]
        signature_builder.post_signature_sms_token do |on|
          on.success do
            flash_path = 'dashboard/internship_agreements/signature/flash_new_code'
            respond_to do |format|
              format.turbo_stream do
                render turbo_stream:
                  turbo_stream.replace('code-request',
                                       partial: flash_path,
                                       locals: { notice: 'Un nouveau code a été envoyé' })
              end
            end
          end
          on.failure do |error|
            err_msg = "Une erreur est survenue et votre demande n'a pas été traitée"
            flash_path = 'dashboard/internship_agreements/signature/flash_new_code'
            respond_to do |format|
              format.turbo_stream do
                render turbo_stream:
                  turbo_stream.replace('code-request',
                                       partial: flash_path,
                                       locals: { alert: err_msg })
              end
            end
          end
        end
      end

      def signature_code_validate
        authorize! :sign_internship_agreements, InternshipAgreement

        @agreement_ids = user_params[:agreement_ids]
        err_path = 'dashboard/internship_agreements/signature/code_error_messages'
        ok_path = 'dashboard/internship_agreements/signature/modal_handwrite_sign'
        signature_builder.signature_code_validate do |on|
          on.success do
            respond_to do |format|
              format.turbo_stream do
                render turbo_stream:
                  turbo_stream.replace('internship-agreement-group',
                                       partial: ok_path,
                                       locals: { current_user:,
                                                 agreement_ids: @agreement_ids })
              end
            end
          end
          on.failure do |error|
            respond_to do |format|
              format.turbo_stream do
                render turbo_stream:
                  turbo_stream.replace('error-messages',
                                       partial: err_path,
                                       locals: { error_message: error.errors.full_messages.join(','),
                                                 agreement_ids: @agreement_ids })
              end
            end
          end
          on.argument_error do |error_msg|
            respond_to do |format|
              format.turbo_stream do
                render turbo_stream:
                  turbo_stream.replace('error-messages',
                                       partial: err_path,
                                       locals: { error_message: error_msg.message,
                                                 agreement_ids: @agreement_ids })
              end
            end
          end
        end
      end

      def handwrite_sign
        authorize! :sign_internship_agreements, InternshipAgreement
        signature_builder.handwrite_sign do |on|
          on.success do |signatures|
            redirect_to dashboard_internship_agreements_path,
                        notice: "Votre signature a été enregistrée pour #{signatures.size} " \
                                "#{'convention'.pluralize(signatures.size)} de stage"
          end
          on.failure do |sig|
            logger.info '================================'
            logger.info "sig.errors.full_messages [agreement: sig.internship_agreement_id]: #{sig.errors.full_messages}"
            logger.info '================================'
            logger.info ''
            redirect_to dashboard_internship_agreements_path,
                        alert: 'Votre signature n\'a pas été enregistrée'
          end
          on.argument_error do |error|
            logger.info '================================'
            logger.info "error : #{error}"
            logger.info '================================'
            logger.info ''
            redirect_to dashboard_internship_agreements_path,
                        alert: 'Votre signature n\'a pas été détectée'
          end
        end
      end

      def school_management_group_signature
        redirect_to dashboard_internship_agreements_path and return unless params[:ids].present?

        params[:ids].split(',').each do |id|
          internship_agreement = current_user.internship_agreements.find(id)
          authorize! :sign_internship_agreements, internship_agreement
        end

        @internship_agreements = current_user.internship_agreements.where(id: params[:ids])
      end

      def school_management_group_sign
        redirect_to dashboard_internship_agreements_path and return unless params[:ids].present?

        update_school_signature if params[:internship_agreement][:signature].present?

        params[:ids].split(',').each do |id|
          internship_agreement = current_user.internship_agreements.find(id)
          authorize! :sign_internship_agreements, internship_agreement
          update_school_signature if params[:internship_agreement][:signature].present?

          Signature.create(internship_agreement: internship_agreement,
                           signatory_role: 'school_manager',
                           user_id: current_user.id,
                           signatory_ip: request.remote_ip,
                           signature_date: Time.now,
                           signature_phone_number: '0111223344')

          if internship_agreement.signatures_started?
            internship_agreement.signatures_finalize!
          else
            internship_agreement.sign!
          end
        end

        redirect_to dashboard_internship_agreements_path,
                    flash: { success: 'Les conventions ont été signées.' }
      end

      private

      def starting_path(current_user)
        path_with_phone    = 'dashboard/internship_agreements/signature/modal_code_submit'
        path_without_phone = 'dashboard/internship_agreements/signature/modal_phone_request'
        current_user.formatted_phone.present? ? path_with_phone : path_without_phone
      end

      def signature_builder
        @signature_buider = Builders::SignatureBuilder.new(
          user: current_user,
          context: :web,
          params: user_params
        )
      end

      def allowed_params
        %i[
          id
          phone_suffix
          phone_prefix
          signature_image
          agreement_ids
        ].concat((0..5).map { |index| "digit-code-target-#{index}".to_sym })
          .concat([internship_agreement_ids: []])
      end

      def user_params
        params.require(:user).permit(*allowed_params)
      end

      def update_school_signature
        school = current_user.school
        school.signature = params[:internship_agreement][:signature]
        school.save
      end
    end
  end
end
