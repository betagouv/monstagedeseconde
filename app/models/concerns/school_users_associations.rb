module SchoolUsersAssociations
  extend ActiveSupport::Concern

  included do
    has_many :user_schools, dependent: :destroy
    has_many :users, -> { kept }
    has_many :all_users, class_name: 'User'

    has_many :students, dependent: :nullify,
                        class_name: 'Users::Student'

    has_many :school_managements, dependent: :nullify,
                                  class_name: 'Users::SchoolManagement'

    has_many :school_managers, -> { where(role: :school_manager) },
             through: :user_schools,
             source: :user,
             class_name: 'Users::SchoolManagement'
    has_many :teachers, -> { where(role: :teacher) },
             through: :user_schools,
             source: :user,
             class_name: 'Users::SchoolManagement'
    has_many :others, -> { where(role: :other) },
             through: :user_schools,
             source: :user,
             class_name: 'Users::SchoolManagement'
    has_many :cpes, -> { where(role: :cpe) },
             through: :user_schools,
             source: :user,
             class_name: 'Users::SchoolManagement'
    has_many :admin_officers, -> { where(role: :admin_officer) },
             through: :user_schools,
             source: :user,
             class_name: 'Users::SchoolManagement'
  end
end
