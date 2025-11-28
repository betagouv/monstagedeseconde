# frozen_string_literal: true

module Dashboard::MultiStepper
  # Step 1 of internship offer creation: fill in company info
  class MultiActivitiesController < ApplicationController
    before_action :authenticate_user!

    # render step 1
    def new
      # authorize! :create, Activity

      # @internship_occupation = Activity.new
    end

    private
  end
end
