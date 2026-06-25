# frozen_string_literal: true

module Dashboard
  module Students
    class InternshipApplicationsController < ApplicationController
      include ApplicationTransitable
      before_action :authenticate_user!, except: %i[show]
      before_action :set_current_student
      before_action :set_internship_application, except: %i[index]

      MAGIC_EXPIRATION_TIME = 3.days

      def index
        authorize! :dashboard_index, @current_student
        @internship_applications = @current_student.internship_applications
                                                   .includes(:internship_offer, :student, :weeks)
                                                   .order_by_aasm_state_for_student
                                                   .order(created_at: :desc)
        @submitted_internship_applications = @internship_applications.where(aasm_state: InternshipApplication::SUBMITTED_LIKE_STATES)
        @validated_internship_applications = @internship_applications.validated_by_employer
        @approved_internship_applications  = @internship_applications.approved
        @canceled_internship_applications  = @internship_applications.where(aasm_state: InternshipApplication::CANCELED_STATES)
        @rejected_internship_applications  = @internship_applications.rejected
        @expired_internship_applications   = @internship_applications.where(aasm_state: InternshipApplication::EXPIRED_STATES)
        @internship_agreements = @approved_internship_applications.includes(:internship_agreement)
                                                                  .filter_map(&:internship_agreement)
      end

      # 0: no magic magic_link_tracker - status quo - default value is 0
      # 1: magic_link_tracker successfully clicked
      # 2: magic_link_tracker clicked but expired
      def show
        @prez_application = Presenters::InternshipApplication.new(@internship_application, current_user)
        if params[:sgid].present? && magic_fetch_student&.student? && magic_fetch_student.id == @current_student.id
          @internship_application.update(magic_link_tracker: 1)
          @internship_application_sgid = @internship_application.to_sgid(expires_in: MAGIC_EXPIRATION_TIME).to_s
          render "dashboard/students/internship_applications/making_decisions" and return
        elsif params[:sgid].present?
          @internship_application.update(magic_link_tracker: 2)
          redirect_to(
            dashboard_students_internship_application_path(
              student_id: @current_student.id,
              uuid: @internship_application.uuid
            )
          ) and return
        else
          authenticate_user!
        end
        authorize! :dashboard_show, @internship_application
        @internship_offer = @internship_application.internship_offer
      end

      def edit
        authorize! :internship_application_edit, @internship_application
        @internship_offer = @internship_application.internship_offer
      end

      def resend_application
        authorize! :internship_application_edit, @internship_application
        if @internship_application.max_dunning_letter_count_reached?
          redirect_to dashboard_students_internship_applications_path(@current_student),
                      alert: "Vous avez atteint le nombre maximum de relances pour cette candidature"
        else
          increase_dunning_letter_count
          EmployerMailer.resend_internship_application_submitted_email(internship_application: @internship_application).deliver_now
          redirect_to dashboard_students_internship_application_path(student_id: @current_student.id, uuid: @internship_application.uuid),
                      notice: "Votre candidature a bien été renvoyée"
        end
      end

      def relaunch_legal_representative_sign_email
        internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
        authorize! :relaunch_legal_representative_sign_email, internship_agreement

        legal_representative_data = synchronize_legal_representative_data(internship_agreement, current_user)
        @internship_application = internship_agreement.internship_application

        if internship_agreement.nil? || legal_representative_data.blank? || legal_representative_data.values.all? { |rep| rep[:email].blank? }
          redirect_to dashboard_students_internship_application_path(student_id: @current_student.id, uuid: @internship_application.uuid),
                      alert: "Aucun représentant légal trouvé pour cette convention"
        elsif internship_agreement.signed_by_legal_representative?
          redirect_to dashboard_students_internship_application_path(student_id: @current_student.id, uuid: @internship_application.uuid),
                      alert: "La convention a déjà été signée par le représentant légal"
        else
          representative_count = legal_representative_data.keys.count
          if representative_count.zero?
            redirect_to dashboard_students_internship_application_path(student_id: @current_student.id, uuid: @internship_application.uuid),
                        alert: "Aucun représentant légal trouvé pour cette convention. Rendez-vous dans 'mon compte'"
          else
            legal_representative_data.values.each do |rep|
              if rep.present? && rep[:email].present? && rep[:email].strip.present?
                GodMailer.notify_student_legal_representatives_can_sign_email(
                  internship_agreement: internship_agreement,
                  representative: rep
                ).deliver_now
              end
            end
            redirect_to dashboard_students_internship_application_path(student_id: @current_student.id, uuid: @internship_application.uuid),
                        notice: "Les emails de relance ont bien été envoyés"
          end
        end
      end

      private

      def synchronize_legal_representative_data(internship_agreement, current_user)
        legal_representative_data = internship_agreement&.legal_representative_data || {}
        return legal_representative_data if legal_representative_data.blank?

        current_email = current_user.legal_representative_email
        return legal_representative_data if current_email.blank?
        return legal_representative_data if current_email.in?(
          legal_representative_data.values.map { |rep| rep[:email] }
        )

        representative = {
          full_name: current_user.legal_representative_full_name,
          email: current_email
        }

        primary_representative = legal_representative_data[:student_legal_representative]

        if primary_representative.blank? || primary_representative[:full_name].blank?
          legal_representative_data[:student_legal_representative] = representative.merge(nr: 1)
        elsif primary_representative[:full_name] == current_user.legal_representative_full_name
          primary_representative[:email] = current_email
        else
          legal_representative_data[:student_legal_representative_2] = representative.merge(nr: 2)
        end

        legal_representative_data
      end

      def magic_fetch_student
        GlobalID::Locator.locate_signed(params[:sgid])
      end

      def set_current_student
        @current_student = ::Users::Student.find(params[:student_id])
      end

      def set_internship_application
        internship_agreement = InternshipAgreement.find_by(uuid: params[:uuid])
        if internship_agreement.present?
          @internship_application = internship_agreement.internship_application
        else
          @internship_application = @current_student.internship_applications.find_by(uuid: params[:uuid])
        end
        raise ActiveRecord::RecordNotFound if @internship_application.nil?
      end

      def increase_dunning_letter_count
        current_count = @internship_application.dunning_letter_count
        @internship_application.update(dunning_letter_count: current_count + 1)
      end
    end
  end
end
