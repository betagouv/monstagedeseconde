# frozen_string_literal: true

module Acl
  class Reporting
    def allowed?
      department_name_from_params = params[:department].try(:downcase)
      return false if department_name_from_params.nil?
      
      user.department_name.try(:downcase) == department_name_from_params
    end

    def ministry_statistician_allowed?
      user.respond_to?(:ministries)
    end

    private

    attr_reader :params, :user
    def initialize(params:, user:)
      @params = params
      @user = user
    end
  end
end
