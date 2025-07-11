# postgis type
require 'nested_form/engine'
require 'nested_form/builder_mixin'
require 'school_year/base'
require 'school_year/current'
class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Types::Hidden
  RailsAdmin::Config::Fields::Types.register(self)
end

# daterange type
class RailsAdmin::Config::Fields::Types::Daterange < RailsAdmin::Config::Fields::Base
  RailsAdmin::Config::Fields::Types.register(self)
end

# https://github.com/railsadminteam/rails_admin/issues/2502#issuecomment-504612818 lead to the following monkey-patch
class RailsAdmin::Config::Fields::Types::Json
  register_instance_option :formatted_value do
    if value.is_a?(Hash) || value.is_a?(Array)
      JSON.pretty_generate(value)
    else
      value
    end
  end

  def parse_value(value)
    value.present? ? JSON.parse(value) : nil
  rescue JSON::ParserError
    value
  end
end
%w[kpi.rb switch_user.rb publish.rb].each do |action|
  require Rails.root.join('lib', 'rails_admin', 'config', 'actions', action)
end
stats_path = "/reporting/dashboards?school_year=#{SchoolYear::Current.new.offers_beginning_of_period.year}"

RailsAdmin.config do |config|
  config.asset_source = :webpacker
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)
  config.main_app_name = ['1élève1stage']

  ## == CancanCan ==
  config.authorize_with :cancancan

  config.parent_controller = 'AdminController'
  config.model 'User' do
    navigation_icon 'fas fa-user'
  end

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard do
      show_in_navigation false
      statistics false
    end
    root :kpi do
      show_in_navigation false
    end

    index
    new
    bulk_delete
    show
    edit do
      except %w[School
                InternshipOfferKeyword
                Users::SchoolManagement]
    end
    delete do
      except %w[School
                InternshipOfferKeyword
                Users::SchoolManagement]
    end

    switch_user do
      except ['Users::God']
    end

    export
    publish do
      only ['InternshipOffers::WeeklyFramed']
    end
  end

  config.default_items_per_page = 50

  config.included_models = %w[School
                              Sector
                              Academy
                              AcademyRegion
                              Group
                              User
                              InternshipOfferKeyword
                              InternshipOffers::WeeklyFramed
                              InternshipOffers::Api
                              InternshipApplication
                              InternshipAgreement
                              Operator
                              Users::Student
                              Users::SchoolManagement
                              Users::PrefectureStatistician
                              Users::MinistryStatistician
                              Users::EducationStatistician
                              Users::AcademyStatistician
                              Users::AcademyRegionStatistician
                              Users::Operator
                              Users::Employer
                              Users::God]

  config.navigation_static_links = {
    'Ajouter un établissement' => '/ecoles/nouveau',
    'Supprimer un étudiant, un employeur' => '/utilisateurs/anonymiseur',
    'Tranformer un compte' => '/utilisateurs/transform_input',
    'Stats' => stats_path,
    'Sidekiq' => '/sidekiq',
    'Feature flip' => '/admin/flipper/',
    'AB Testing' => '/split'
  }
end
