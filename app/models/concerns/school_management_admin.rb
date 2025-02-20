module SchoolManagementAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      weight 4
      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        field :school
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
      end
    end
  end
end
