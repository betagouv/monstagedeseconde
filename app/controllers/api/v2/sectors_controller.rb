module Api
  module V2
    class SectorsController < Api::Shared::SectorsController
      include Api::AuthV2
    end
  end
end
