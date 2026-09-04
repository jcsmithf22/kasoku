Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :sign_up

  namespace :settings do
    resource :password, only: %i[show update]
    resource :profile, only: %i[show update]
    resource :email, only: %i[show update]
    resource :user, only: %i[show destroy]
    root to: redirect("/settings/profile")
  end

  namespace :email do
    resources :confirmations, param: :token, only: [ :show ]
  end

  resources :spaces, except: %i[index new] do
    resources :todos, only: %i[create update destroy]
    resources :details, only: %i[index], controller: "spaces/details"
    resources :members, only: %i[index new create destroy], controller: "spaces/members"
  end

  namespace :users do
    resources :members, only: :destroy
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "spaces#index"
end
