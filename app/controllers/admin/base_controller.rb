# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_god!

    layout "no_link_layout"

    private

    def authorize_god!
      authorize! :access, :rails_admin
    end
  end
end
