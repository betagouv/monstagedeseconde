# frozen_string_literal: true

module Users
  class God < User
    after_initialize :enforce_otp_for_god

    def custom_dashboard_path
      url_helpers.rails_admin_path
    end

    def dashboard_name
      'Admin'
    end

    def god? = true

    def presenter
      Presenters::God.new(self)
    end

    rails_admin do
      weight 8
    end

    private

    def enforce_otp_for_god
      self.otp_required_for_login = true if new_record? || !otp_required_for_login
    end
  end
end
