module EduconnectLogout
  extend ActiveSupport::Concern

  def sign_out_and_redirect(resource_or_scope)
    if session[:state].present? && resource_or_scope.is_a?(Users::Student)
      Rails.logger.info('Logging out from Educonnect')
      response = Services::EduconnectConnection.logout(session[:id_token])
      Rails.logger.info("Response logout: #{response.inspect}")
    end

    super
  end
end
