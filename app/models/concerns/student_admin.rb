module StudentAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      weight 2

      list do
        fields(*UserAdmin::DEFAULT_FIELDS)
        field(:ine)
        field :school
        field :class_room
        fields(*UserAdmin::ACCOUNT_FIELDS)

        scopes(UserAdmin::DEFAULT_SCOPES)
      end

      edit do
        fields(*UserAdmin::DEFAULT_EDIT_FIELDS)
        field :birth_date
        field :school
        field :gender
      end

      show do
        field(:ine)
        fields(*UserAdmin::DEFAULT_FIELDS)
        field :confirmation_sent_at do
          date_format 'KO'
          strftime_format '%d/%m/%Y'
        end

        field :phone
        field :school do
          visible do
            bindings[:object].respond_to?(:school)
          end
        end
        field :failed_attempts do
          label 'Nombre de tentatives'
        end
        field :sign_in_count
        field :current_sign_in_at do
          label 'Dernière connexion'
        end
      end
    end
  end
end
