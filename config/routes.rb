Rails.application.routes.draw do
  root "resources#index"

  get "ui_kit", to: "ui_kit#index"

  resources :resources, only: %i[index show new create] do
    get :availability, on: :member
  end
  resources :bookings, only: %i[create destroy]
  get "my_bookings", to: "bookings#index", as: :my_bookings

  get "sign_up", to: "registrations#new", as: :sign_up
  post "sign_up", to: "registrations#create"

  get "sign_in", to: "sessions#new", as: :sign_in
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy", as: :sign_out

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
