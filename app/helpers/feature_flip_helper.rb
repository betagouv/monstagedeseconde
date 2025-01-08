# frozen_string_literal: true

module FeatureFlipHelper
  def support_listable?(user)
    return false if user&.employer? || user&.operator?

    true
  end
end
