# frozen_string_literal: true

require 'sidekiq/web'
root_destination = if ENV.fetch('HOLIDAYS_MAINTENANCE', false) == 'true'
                     'maintenance_estivale'
                   elsif ENV.fetch('EMPLOYERS_ONLY', false) == 'true'
                     'pro_landing'
                   else
                     'home'
                   end

Rails.application.routes.draw do
  # ------------------ SCOPE START ------------------
  scope(path_names: { new: 'nouveau', edit: 'modification' }) do
    authenticate :user, ->(u) { u.god? } do
      # sidekiq
      mount Sidekiq::Web => '/sidekiq'
      match '/split' => Split::Dashboard,
            anchor: false,
            via: %i[get post delete]

      # flipper
      mount Flipper::UI.app(Flipper) => '/admin/flipper'
    end

    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    mount ActionCable.server => '/cable'

    devise_for :users, path: 'utilisateurs', path_names: {
      sign_in: 'connexion',
      sign_out: 'deconnexion',
      sign_up: 'inscription',
      password: 'mot-de-passe'
    }, controllers: {
      confirmations: 'users/confirmations',
      registrations: 'users/registrations',
      sessions: 'users/sessions',
      passwords: 'users/passwords'
    }

    devise_scope :user do
      get '/auth/fim/callback', to: 'callbacks#fim', as: 'fim_callback'
      get '/auth/educonnect/callback', to: 'callbacks#educonnect', as: 'educonnect_callback'
      # get '/auth/failure', to: 'sessions#failure'
      get 'utilisateurs/choisir_profil', to: 'users/registrations#choose_profile',
                                         as: 'users_choose_profile'
      get 'utilisateurs/choisir_connexion', to: 'users/sessions#choose_connection',
                                            as: 'users_choose_connection'
      get 'utilisateurs/choisir_connexion_test', to: 'users/sessions#choose_connection_test',
                                                 as: 'users_choose_connection_test'
      get '/utilisateurs/inscriptions/en-attente', to: 'users/registrations#confirmation_standby',
                                                   as: 'users_registrations_standby'
      get '/utilisateurs/inscriptions/referent-en-attente', to: 'users/registrations#statistician_standby',
                                                            as: 'statistician_standby'
      get '/utilisateurs/inscriptions/en-attente-telephone', to: 'users/registrations#confirmation_phone_standby',
                                                             as: 'users_registrations_phone_standby'
      post '/utilisateurs/inscriptions/validation-telephone', to: 'users/registrations#phone_validation',
                                                              as: 'phone_validation'
      get '/utilisateurs/mot-de-passe/modification-par-telephone', to: 'users/passwords#edit_by_phone',
                                                                   as: 'phone_edit_password'
      put '/utilisateurs/mot-de-passe/update_by_phone', to: 'users/passwords#update_by_phone',
                                                        as: 'phone_update_password'
      get '/utilisateurs/mot-de-passe/initialisation', to: 'users/passwords#set_up',
                                                       as: 'set_up_password'
      post '/utilisateurs/renvoyer-le-code-de-confirmation', to: 'users/registrations#resend_confirmation_phone_token',
                                                             as: 'resend_confirmation_phone_token'
    end

    # resources :identities, path: 'identites', only: %i[new create]
    resources :url_shrinkers, path: 'c', only: %i[] do
      get :o, on: :member
    end

    resources :coded_crafts, only: [] do
      collection do
        post :search
      end
    end

    resources :schools, path: 'ecoles', only: %i[new create]

    resources :internship_offer_keywords, only: [] do
      collection do
        post :search
      end
    end

    resources :internship_offers, path: 'offres-de-stage', only: %i[index show] do
      collection do
        get :search, path: 'recherche'
      end
      resources :internship_applications, path: 'candidatures', only: %i[new create index show update], param: :uuid do
        member do
          get :edit_transfer
          post :transfer
          get :completed
        end
      end
      member do
        post :apply_count
      end
    end

    resources :companies, path: 'organisations', only: %i[index show] do
      member do
        post :contact
      end
      collection do
        get :search, path: 'recherche'
      end
    end
    resources :favorites, only: %i[create destroy index]

    get '/utilisateurs/transform_input', to: 'users#transform_input' # display
    get '/utilisateurs/transform', to: 'users#transform_form' # identify and show parameters
    post '/utilisateurs/transform', to: 'users#transform_user' # transform

    get '/utilisateurs/anonymiseur', to: 'users#anonymize_form'
    get '/utilisateurs/identifier', to: 'users#identify_user'
    post '/utilisateurs/anonymiser', to: 'users#anonymize_user'

    namespace :api, path: 'api' do
      # TO DO : fix this redirect
      # match '/*path', via: %i[get post put delete], to: redirect { |path_params, _req|
      #   path = path_params[:path]
      #   return false if path.start_with?('v1/') || path.start_with?('v2/')

      #   "/api/v1/#{path}"
      # }

      namespace :v1 do
        resources :internship_offers, only: %i[create update destroy index] do
          get :search, on: :collection
        end
        resources :schools, only: [] do
          collection do
            post :nearby
            post :search
          end
        end
        resources :coded_crafts, only: [] do
          get :search, on: :collection
        end
        resources :sectors, only: :index
      end

      namespace :v2 do
        post 'auth/login', to: 'auth#login'
        resources :internship_offers, only: %i[create update destroy index] do
          get :search, on: :collection
        end
        resources :schools, only: [] do
          collection do
            post :nearby
            post :search
          end
        end
        resources :coded_crafts, only: [] do
          get :search, on: :collection
        end
        resources :sectors, only: :index
      end
    end

    # ------------------ DASHBOARD START ------------------
    namespace :dashboard, path: 'tableau-de-bord' do
      resources :team_member_invitations, path: 'invitation-equipes', only: %i[create index new destroy] do
        patch :join, to: 'team_member_invitations#join', on: :member
        post :resend_invitation, to: 'team_member_invitations#resend_invitation', on: :member
      end

      post 'internship_applications/update_multiple', to: 'internship_applications#update_multiple',
                                                      as: :update_multiple_internship_applications

      resources :internship_agreements, path: 'conventions-de-stage', except: %i[destroy], param: :uuid do
        get 'school_management_signature', on: :member
        post 'school_management_sign', on: :member
      end
      resources :users, path: 'signatures', only: %i[update], module: 'group_signing' do
        member do
          post 'start_signing'
          post 'reset_phone_number'
          post 'resend_sms_code'
          post 'signature_code_validate'
          post 'handwrite_sign'
          post 'school_management_group_signature'
          post 'school_management_group_sign'
        end
      end

      resources :schools, path: 'ecoles', only: %i[index edit update show] do
        patch :update_signature, on: :member
        resources :invitations, only: %i[new create index destroy], module: 'schools'
        get '/resend_invitation', to: 'schools/invitations#resend_invitation', module: 'schools'
        resources :users, path: 'utilisateurs', only: %i[destroy update index], module: 'schools'

        resources :class_rooms, path: 'classes', only: %i[index new create edit update show destroy],
                                module: 'schools' do
          resources :students, path: 'eleves', only: %i[update index new create], module: 'class_rooms'
        end
        put '/update_students_by_group', to: 'schools/students#update_by_group', module: 'schools'
      end

      resources :internship_offer_areas, path: 'espaces', except: %i[show] do
        get :filter_by_area, on: :member
        resources :area_notifications, path: 'notifications-d-espace', only: %i[edit update index],
                                       module: 'internship_offer_areas' do
          patch :flip, on: :member
        end
      end

      resources :internship_offers, path: 'offres-de-stage', except: %i[show] do
        resources :internship_applications, path: 'candidatures', only: %i[update index show],
                                            module: 'internship_offers', param: :uuid do
          patch :set_to_read, on: :member
          get :school_details, on: :member
        end
        post :publish, on: :member
        post :remove, on: :member
        patch :republish, to: 'internship_offers#republish', on: :member
      end

      namespace :stepper, path: 'etapes' do
        # legacy stepper routes
        resources :organisations, only: %i[create new edit update]
        resources :internship_offer_infos, path: 'offre-de-stage-infos', only: %i[create new edit update]
        resources :hosting_infos, path: 'accueil-infos', only: %i[create new edit update]
        resources :practical_infos, path: 'infos-pratiques', only: %i[create new edit update]
        resources :tutors, path: 'tuteurs', only: %i[create new]
        # new stepper path
        resources :internship_occupations, path: 'metiers_et_localisation', only: %i[create new edit update]
        resources :entreprises, path: 'entreprise', only: %i[create new edit update]
        resources :plannings, path: 'planning', only: %i[create new edit update]
      end

      namespace :students, path: '/:student_id/' do
        resources :internship_applications, path: 'candidatures', only: %i[index show edit update], param: :uuid do
          post :resend_application, on: :member
        end
      end
      get 'candidatures', to: 'internship_offers/internship_applications#user_internship_applications'
    end
    # ------------------ DASHBOARD END ------------------
  end
  # ------------------ SCOPE END ------------------
  namespace :reporting, path: 'reporting' do
    get '/dashboards', to: 'dashboards#index'

    get '/schools', to: 'schools#index'
    get '/employers_internship_offers', to: 'internship_offers#employers_offers'
    get 'internship_offers', to: 'internship_offers#index'
    get 'operators', to: 'operators#index'
    put 'operators', to: 'operators#update'
  end

  get 'api_address_proxy/search', to: 'api_address_proxy#search', as: :api_address_proxy_search
  get 'api_sirene_proxy/search', to: 'api_sirene_proxy#search', as: :api_sirene_proxy_search
  get 'api_entreprise_proxy/search', to: 'api_entreprise_proxy#search', as: :api_entreprise_proxy_search
  get 'api_city_proxy/search', to: 'api_city_proxy#search', as: :api_city_proxy_search

  get 'mon-compte(/:section)', to: 'users#edit', as: 'account'
  patch 'mon-compte', to: 'users#update'
  patch 'account_password', to: 'users#update_password'
  patch 'answer_survey', to: 'users#answer_survey'
  get '/magic_link', to: 'magic_links#show', as: :magic_link

  get '/accessibilite', to: 'pages#accessibilite'
  get '/conditions-d-utilisation', to: 'pages#conditions_d_utilisation'
  # TODO
  # get '/conditions-d-utilisation-service-signature', to: 'pages#conditions_utilisation_service_signature',
  get '/contact', to: 'pages#contact', as: 'contact'
  get '/documents-utiles', to: 'pages#documents_utiles'
  get '/javascript-required', to: 'pages#javascript_required'
  get '/mentions-legales', to: 'pages#mentions_legales'
  get '/les-10-commandements-d-une-bonne-offre', to: 'pages#les_10_commandements_d_une_bonne_offre'
  get '/operators', to: 'pages#operators'
  get '/politique-de-confidentialite', to: 'pages#politique_de_confidentialite'
  post '/newsletter', to: 'newsletter#subscribe'
  get '/inscription-permanence', to: 'pages#register_to_webinar'
  get '/recherche-entreprises', to: 'pages#search_companies'
  post '/visitor_apply', to: 'pages#visitor_apply'
  get '/educonnect_deconnexion_responsable', to: 'pages#educonnect_logout_responsible',
                                             as: :educonnect_logout_responsible
  # TODO
  # To be removed after june 2023
  get '/register_to_webinar', to: 'pages#register_to_webinar'
  get '/eleves', to: 'pages#student_landing'
  get '/eleves/connexion', to: 'pages#student_login', as: :student_login
  get '/professionnels', to: 'pages#pro_landing'
  get '/professionnels/connexion', to: 'pages#pro_login', as: :pro_login
  get '/partenaires', to: 'pages#regional_partners_index', as: :partners
  get '/equipe-pedagogique', to: 'pages#school_management_landing'
  get '/equipe-pedagogique/connexion', to: 'pages#school_management_login', as: :school_management_login
  get '/referents', to: 'pages#statistician_landing'
  get '/referents/connexion', to: 'pages#statistician_login', as: :statistician_login
  get '/maintenance_estivale', to: 'pages#maintenance_estivale'
  post '/maintenance_messaging', to: 'pages#maintenance_messaging'
  post '/waiting_list', to: 'pages#waiting_list'

  # Redirects
  # get '/dashboard/internship_offers/:id', to: redirect('/internship_offers/%<id>s', status: 302)
  get '/dashboard/internship_offers/:id', to: redirect('/internship_offers/#{id}', status: 302)

  resources :school_switches, only: [:create]

  root to: "pages##{root_destination}"

  get '/400', to: 'errors#bad_request'
  get '/404', to: 'errors#not_found'
  get '/406', to: 'errors#not_acceptable'
  get '/422', to: 'errors#unacceptable'
  get '/429', to: 'errors#not_found'
  get '/500', to: 'errors#internal_error'
end
