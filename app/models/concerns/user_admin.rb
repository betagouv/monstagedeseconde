# frozen_string_literal: true

module UserAdmin
  extend ActiveSupport::Concern

  DEFAULT_FIELDS      = %i[id email first_name last_name]
  ACCOUNT_FIELDS      = %i[confirmed_at sign_in_count]
  DEFAULT_EDIT_FIELDS = %i[first_name last_name email phone password confirmed_at type discarded_at]
  DEFAULT_SCOPES      = %i[kept discarded]

  included do
  end
end
