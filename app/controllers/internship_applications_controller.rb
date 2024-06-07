# frozen_string_literal: true

class InternshipApplicationsController < ApplicationController
  before_action :persist_login_param, only: %i[new]
  before_action :authenticate_user!, except: %i[update]
  before_action :set_internship_offer

  def index
    set_intership_applications
    authorize! :read, @internship_offer
    authorize! :index, InternshipApplication
  end

  def new
    authorize! :apply, @internship_offer
    @internship_application = InternshipApplication.new(
      internship_offer_id: params[:internship_offer_id],
      internship_offer_type: 'InternshipOffer',
      student: current_user)
  end

  # alias for draft
  def show
    @internship_application = @internship_offer.internship_applications.find_by(uuid: params[:uuid])
    authorize! :submit_internship_application, @internship_application
  end

  # alias for submit/update
  def update
    @internship_application = @internship_offer.internship_applications.find_by(uuid: params[:uuid])
    authorize! :submit_internship_application, @internship_application

    destination = dashboard_students_internship_applications_path(student_id: current_user.id, notice_banner: true)
    if params[:transition] == 'submit!'
      @internship_application.submit!
      @internship_application.save!
    else
      @internship_application.update(update_internship_application_params)
      destination = internship_offer_internship_application_path(@internship_offer, uuid: @internship_application.uuid)
    end
    redirect_to destination
  rescue AASM::InvalidTransition
    redirect_to dashboard_students_internship_applications_path(current_user, uuid: @internship_application.uuid),
                flash: { warning: 'Votre candidature avait déjà été soumise' }
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Erreur dans la saisie de votre candidature'
    render 'internship_applications/show'
  end

  # students can apply for one internship_offer
  def create
    set_internship_offer
    authorize! :apply, @internship_offer

    appli_params = {user_id: current_user.id}.merge(create_internship_application_params)
    appli_params = sanitizing_params(appli_params)
    @internship_application = InternshipApplication.new(appli_params)
    if @internship_application.save
      redirect_to internship_offer_internship_application_path(@internship_offer,
                                                             uuid: @internship_application.uuid)
    else
      Rails.logger.error(@internship_application.errors.full_messages)
      render 'new', status: :bad_request
    end
  end

  def completed
    set_internship_offer
    @internship_application = @internship_offer.internship_applications.find_by(uuid: params[:uuid])
    authorize! :submit_internship_application, @internship_application

    @suggested_offers = Finders::InternshipOfferConsumer.new(
      params: {
        latitude: @internship_application.student.school.coordinates.latitude,
        longitude: @internship_application.student.school.coordinates.longitude
      },
      user: current_user_or_visitor
    ).all
     .includes([:sector])
     .last(6)
  end

  def edit_transfer
    @internship_application = InternshipApplication.find_by(uuid: params[:uuid])
    authorize! :transfer, @internship_application
  end

  def transfer
    @internship_application = InternshipApplication.find_by(uuid: params[:uuid])
    authorize! :transfer, @internship_application
    # send email to the invited employer
    if transfer_params[:destinations].present?
      destinations = transfer_params[:destinations].split(',').compact.map(&:strip)
      faulty_emails = check_transfer_destinations(destinations)
      if faulty_emails.empty?
        @internship_application.transfer!
        @internship_application.generate_token

        destinations.each do |destination|
          EmployerMailer.transfer_internship_application_email(
            internship_application: @internship_application,
            employer_id: current_user.id,
            email: destination,
            message: transfer_params[:comment]
          ).deliver_later
        end
        redirect_to dashboard_candidatures_path,
                    flash: { success: 'La candidature a été transmise avec succès' }
      else
        target_path = edit_transfer_internship_offer_internship_application_path(@internship_application.internship_offer, @internship_application)
        flash_error_message = "Les adresses emails suivantes sont invalides : #{faulty_emails.join(', ')}" \
                              ". Aucun transfert n'a été effectué, aucun email n'a été émis."
        redirect_to(target_path, flash: { danger: flash_error_message }) and return
      end
    else
      redirect_to edit_transfer_internship_offer_internship_application_path(@internship_application.internship_offer, @internship_application),
                  flash: { danger: "La candidature n'a pas pu être transmise avec succès, faute de destinataires" }
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: current_user.custom_dashboard_path,
                  alert: e.message
  end

  private

  def set_intership_applications
    @internship_applications = @internship_offer.internship_applications
                                                .order(updated_at: :desc)
                                                .page(params[:page])
  end

  def set_internship_offer
    @internship_offer = InternshipOffer.find(params[:internship_offer_id])
  end

  def update_internship_application_params
    params.require(:internship_application)
          .permit(
            :motivation,
            :student_phone,
            :student_email,
            student_attributes: %i[
              email
              phone
              resume_other
              resume_languages
            ]
          )
  end


  def sanitizing_params(appli_params)
    phone = appli_params["student_phone"]&.gsub(/\s+/, '')
    appli_params.merge!({"student_phone" => phone})
  end

  def check_transfer_destinations(destinations)
    email_errors = []
    destinations.each do |destination|
      destination_is_email = destination.match?(Devise.email_regexp)
      email_errors << destination unless destination_is_email
    end
    email_errors.uniq
  end

  def transfer_params
    params.require(:application_transfer)
          .permit(:comment,
                  :destinations,
                  :destination,
                  :destinataires)
  end

  def create_internship_application_params
    params.require(:internship_application)
          .permit(
            :type,
            :week_id,
            :internship_offer_id,
            :internship_offer_type,
            :motivation,
            :student_phone,
            :student_email,
            :student_address,
            :student_legal_representative_full_name,
            :student_legal_representative_email,
            :student_legal_representative_phone,
            student_attributes: %i[
              email
              phone
              resume_other
              resume_languages
            ]
          )
  end

  def persist_login_param
    session[:as] = params[:as]
  end
end
