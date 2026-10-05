Rails.application.routes.draw do
  # The Assignment 1 landing page is the home of the application
  root "pages#home"

  # Read-only for Assignment 2: nothing creates, edits or deletes records yet
  resources :listings,      only: %i[index show]
  resources :properties,    only: %i[index show]
  resources :neighborhoods, only: %i[index show]
  resources :applications,  only: %i[index show]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
