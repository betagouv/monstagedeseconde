module Api
  module V3
    class SectorsController < Api::Shared::SectorsController
      include Api::AuthV2
    end
  end
end
