# frozen_string_literal: true

module Users
  class God < User
    def custom_dashboard_path
      url_helpers.root_path
    end

    def dashboard_name
      'Admin'
    end

    def god? = true

    def presenter
      Presenters::God.new(self)
    end
  end
end
