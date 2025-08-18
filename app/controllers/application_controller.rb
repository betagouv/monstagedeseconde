# frozen_string_literal: true

require 'uri'
class ApplicationController < ActionController::Base
  include Turbo::Redirection

  # max requests per minute
  MAX_REQUESTS_PER_MINUTE = ENV['MAX_REQUESTS_PER_MINUTE'].to_i

  helper Turbo::FramesHelper if Rails.env.test?
  helper Turbo::StreamsHelper if Rails.env.test?

  before_action :check_host_for_redirection
  before_action :check_for_holidays_maintenance_page
  before_action :check_school_requested
  before_action :check_for_maintenance
  before_action :employers_only_redirect
  before_action :throttle_ip_requests
  before_action :store_user_type_before_logout
  before_action :get_banner_message

  # TODO: Remove following line
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

  def after_sign_out_path_for(resource_or_scope)
    Rails.logger.info("----- Signout path for: #{resource_or_scope.inspect} -----")
    Rails.logger.info("----- User type was : #{cookies[:user_type]} -----")

    if cookies[:user_type] == 'student'
      Rails.logger.info('----- Logout educonnect -----')
      cookies.delete(:user_type)
      root_path(logout: :educonnect)
    elsif cookies[:user_type] == 'school_management'
      Rails.logger.info('----- Logout fim -----')
      cookies.delete(:user_type)
      root_path(logout: :fim)
    else
      super
    end
  end

  def current_user_or_visitor
    current_user || Users::Visitor.new
  end

  def employers_only?
    ENV.fetch('EMPLOYERS_ONLY', false) == 'true'
  end

  def user_presenter
    @user_presenter ||= Presenters::User.new(current_user_or_visitor)
  end
  helper_method :user_presenter, :current_user_or_visitor, :employers_only?

  def check_for_maintenance
    redirect_to '/maintenance.html' if Flipper.enabled?(:maintenance_mode)
  end

  def employers_only_redirect
    return unless employers_only? && request.path == '/'

    redirect_to professionnels_path
  end

  def throttle_ip_requests
    return if Rails.env.test? && ENV.fetch('TEST_WITH_MAX_REQUESTS_PER_MINUTE', false) != 'true'

    ip_address = request.remote_ip
    key = "ip:#{ip_address}:#{Time.now.to_i / 60}"
    count = $redis.incr(key)
    $redis.expire(key, 60) if count == 1
    return unless count > MAX_REQUESTS_PER_MINUTE

    puts "IP #{ip_address} exceeded rate limit, count: #{count}, #{MAX_REQUESTS_PER_MINUTE}"
    respond_to do |format|
      format.html do
        render plain: "Trop de requêtes - Limite d'utilisation de l'application.", status: :too_many_requests
      end
      format.json do
        render json: { error: "Trop de requêtes - Limite d'utilisation de l'application dépassée." },
               status: :too_many_requests
      end
    end
  end

  def strip_content(string)
    string.split("\n")
          .map { |line| line = ActionController::Base.helpers.strip_tags(line).strip }
          .join("\n")
  end

  def log_error(object:, controller: self)
    Rails.logger.error("#{controller.class.name} error: #{object.errors.full_messages.join(', ')}")
  end

  def get_banner_message
    @banner_message = if ENV['PRISMIC_URL'].blank? || ENV['PRISMIC_API_KEY'].blank? || Rails.env.test?
                        nil
                      else
                        message_from_prismic
                      end
  end

  private

  def message_from_prismic
    api = Prismic.api(ENV['PRISMIC_URL'], ENV['PRISMIC_API_KEY'])
    response = api.query([Prismic::Predicates.at('document.type', 'top_banner')])
    response.results.first
  end

  def check_school_requested
    return unless current_user && current_user.missing_school?

    redirect_to account_path(:school), flash: { warning: 'Veuillez choisir un établissement scolaire' }
  end

  def check_for_holidays_maintenance_page
    return unless Flipper.enabled?(:holidays_maintenance) && !holidays_maintenance_redirection_exception?

    redirect_to '/maintenance_estivale.html' and return
  end

  def holidays_maintenance_redirection_exception?
    allowed_paths = %w[/maintenance_estivale.html /contact.html /waiting_list]
    request.path.in?(allowed_paths) ||
      (request.path == '/waiting_list' && request.post?)
  end

  def check_host_for_redirection
    return unless request.host == '1eleve1stage.education.gouv.fr/'

    redirect_to 'https://1eleve1stage.education.gouv.fr', status: :moved_permanently,
                                                          allow_other_host: true
  end

  def store_user_type_before_logout
    return unless current_user

    cookies[:user_type] = case current_user
                          when Users::Student
                            'student'
                          when Users::SchoolManagement
                            'school_management'
                          else
                            'other'
                          end
    Rails.logger.info("User type stored before logout: #{cookies[:user_type]}")
  end

  def build_list_html(list_items, ordered)
    return '' if list_items.empty?

    tag = ordered ? 'ol' : 'ul'
    items_html = list_items.map { |item| "<li>#{item}</li>" }.join("\n")

    "<#{tag}>\n#{items_html}\n</#{tag}>"
  end
end
