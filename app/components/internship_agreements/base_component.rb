module InternshipAgreements
  class BaseComponent < ApplicationComponent
    include Turbo::FramesHelper,
            Turbo::Streams::StreamName,
            Turbo::Streams::Broadcasts

  end
end
