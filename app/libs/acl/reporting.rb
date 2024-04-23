# frozen_string_literal: true

module Acl
  class Reporting
    def allowed?
      return false if params[:department].try(:downcase).nil?
      
      user.try(:department_name).try(:downcase) == params[:department].try(:downcase)
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
