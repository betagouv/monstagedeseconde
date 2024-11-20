module Api
  module V1
    class SectorsController < Api::Shared::SectorsController
      include Api::AuthV1
    end
  end
end
