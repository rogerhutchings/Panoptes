ActionDispatch::Routing::Mapper.send :include, JsonApiRoutes

Rails.application.routes.draw do

  use_doorkeeper do
    controllers authorizations: 'authorizations',
      tokens: 'tokens'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', passwords: 'passwords' }, skip: [ :sessions, :registrations ]

  as :user do
    get "/users/sign_in" => "sessions#new", as: :new_user_session
    post "/users/sign_in" => "sessions#create", as: :user_session
    delete "/users/sign_out" => "sessions#destroy", as: :destroy_user_session

    get "/users/sign_up" => "registrations#new", as: :new_user_registration
    post "/users" => "registrations#create", as: :user_registration
  end

  namespace :api do
    api_version(module: "V1", header: {name: "Accept", value: "application/vnd.api+json; version=1"}) do
      get "/me", to: 'users#me', format: false

      json_api_resources :workflow_contents, versioned: true

      json_api_resources :project_contents
      
      json_api_resources :project_roles
      
      json_api_resources :project_preferences

      json_api_resources :classifications
      
      json_api_resources :memberships
      
      json_api_resources :subjects, versioned: true
      
      json_api_resources :users, except: [:new, :edit, :create],
        links: [:user_groups]
      
      json_api_resources :groups, links: [:users]
      
      json_api_resources :projects, links: [:subject_sets, :workflows]
      
      json_api_resources :workflows, links: [:subject_sets], versioned: true   
      
      json_api_resources :subject_sets, links: [:workflows, :subjects]
      
      json_api_resources :collections, links: [:subjects]

      json_api_resources :subject_queues, links: [:set_member_subjects]
    end
  end

  root to: "home#index"
  match "*path", to: "application#unknown_route", via: :all
end
