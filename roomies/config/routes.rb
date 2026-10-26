Rails.application.routes.draw do
  # The Assignment 1 landing page is the home of the application
  root "pages#home"

  # Who you are acting as. Assignment 4 replaces it with real accounts.
  resource :acting_user, only: :update

  # Catalogs
  resources :neighborhoods
  resources :amenities, except: :show

  # A listing is always created inside a property, and reviews are written from the property page
  resources :properties do
    resources :listings, only: %i[new create]
    resources :reviews,  only: :create
  end

  # Seekers apply from the listing page
  # The host moves a listing through its lifecycle from the listing page
  resources :listings, only: %i[index show edit update destroy] do
    member do
      patch :publish
      patch :withdraw
      patch :mark_rented
    end
    resources :applications, only: :create
  end

  # Hosts propose visits on an application
  # The seeker withdraws; the host shortlists, rejects or accepts
  resources :applications, only: %i[index show] do
    member do
      patch :withdraw
      patch :shortlist
      patch :reject
      patch :accept
    end
    resources :visits, only: :create
  end

  # edit/update reschedule a visit: the old one is cancelled and a new one is proposed
  resources :visits, only: %i[edit update] do
    member do
      patch :confirm
      patch :cancel
      patch :complete
    end
  end

  resources :reviews, only: %i[edit update destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
