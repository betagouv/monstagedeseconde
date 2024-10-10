# frozen_string_literal: true

module Users
  class MinistryStatistician < Statistician
    METABASE_DASHBOARD_ID = 29

    has_many :user_groups,
             foreign_key: :user_id,
             inverse_of: :user
    has_many :groups,
             -> { where is_public: true },
             through: :user_groups
    has_many :organisations

    def ministries
      groups
    end

    def dashboard_name
      'Statistiques nationales'
    end

    def ministry_statistician? = true
    def employer_like? = true

    def presenter
      Presenters::MinistryStatistician.new(self)
    end

    def department_name
      ''
    end
  end
end
