Rails.application.routes.draw do
  get "users/new"
  get "users/create"
  root "spaces#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"

  delete "logout", to: "sessions#destroy"

  get "sign_up", to: "users#new"
  post "sign_up", to: "users#create"

  resources :spaces, except: %i[index new] do
    resources :todos, only: %i[create update destroy]
    resources :members,
              only: %i[index new create destroy],
              controller: "spaces/members"
  end

  resource :profile, only: %i[show edit update], controller: "users"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # PWA routes
  get "webmanifest" => "pwa#manifest"

  # Defines the root path route ("/")
  # root "posts#index"
end
