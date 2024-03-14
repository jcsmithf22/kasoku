Rails.application.routes.draw do
  get "users/new"
  get "users/create"
  root "spaces#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"

  get "sign_up", to: "users#new"
  post "sign_up", to: "users#create"

  resources :spaces, except: %i[index new]

  resource :profile, only: %i[show edit update], controller: "users"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end