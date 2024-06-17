# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include Turbo::Redirection

  # max requests per minute
  MAX_REQUESTS_PER_MINUTE = 100

  helper Turbo::FramesHelper if Rails.env.test?
  helper Turbo::StreamsHelper if Rails.env.test?

  before_action :check_school_requested
  before_action :check_for_maintenance
  before_action :throttle_ip_requests

  default_form_builder Rg2aFormBuilder

  rescue_from(CanCan::AccessDenied) do |_error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à effectuer cette action." })
  end

  def after_sign_in_path_for(resource)
    return resource.after_sign_in_path if resource.is_a?(Users::God)  
    session[:show_student_reminder_modal] = true if resource.needs_to_see_modal?
  
    stored_location_for(resource) || resource.reload.after_sign_in_path || super
  end

  def current_user_or_visitor
    current_user || Users::Visitor.new
  end

  helper_method :user_presenter, :current_user_or_visitor
  def user_presenter
    @user_presenter ||= Presenters::User.new(current_user_or_visitor)
  end

  def check_for_maintenance
    redirect_to '/maintenance.html' if ENV['MAINTENANCE_MODE'] == 'true'
  end

  def throttle_ip_requests
    ip_address = request.remote_ip
    key = "ip:#{ip_address}:#{Time.now.to_i / 60}"
    count = $redis.incr(key)
    $redis.expire(key, 60) if count == 1
  
    if count > MAX_REQUESTS_PER_MINUTE
      respond_to do |format|
        format.html { render plain: "Trop de requêtes - Limite d'utilisation de l'application.", status: :too_many_requests }
        format.json { render json: { error: "Trop de requêtes - Limite d'utilisation de l'application dépassée." }, status: :too_many_requests }
      end
    end
  end

  private

  def check_school_requested
    if current_user && current_user.missing_school?
      redirect_to account_path(:school), flash: {warning: 'Veuillez choisir un établissement scolaire'}
    end
  end
end
