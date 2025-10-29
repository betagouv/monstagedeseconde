module Api::Shared
  class InternshipApplicationsController < Api::ApiBaseController
    before_action :authenticate_api_user!
  end
end