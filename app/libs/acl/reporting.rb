# frozen_string_literal: true

module Acl
  class Reporting
    def allowed?
      requested = normalize(Array(params[:department]))
      return false if requested.empty?

      (requested - allowed_department_names).empty?
    end

    def ministry_statistician_allowed?
      user.respond_to?(:ministries)
    end

    private

    attr_reader :params, :user

    def allowed_department_names
      names = if user.respond_to?(:departments)
                user.departments.map(&:name)
      else
                [ user.department_name ]
      end
      normalize(names)
    end

    def normalize(names)
      names.flatten.filter_map { |name| name.to_s.downcase.strip.presence }
    end

    def initialize(params:, user:)
      @params = params
      @user = user
    end
  end
end
