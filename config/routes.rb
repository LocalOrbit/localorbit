Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :markets do
      resources :market_addresses,   as: :addresses,  path: :addresses
      resources :market_managers,    as: :managers,   path: :managers
      resources :delivery_schedules, path: :deliveries
    end

    get "financials" => "financials#index"
    namespace :financials do
      resources :orders
    end

    resources :organizations do
      resources :users
      resources :locations, except: :destroy do
        collection do
          delete :destroy
          put :update_default
        end
      end
    end

    resources :products do
      resources :lots
      resources :prices
    end

    resource :unit_request, only: :create
    resource :category_request, only: :create
  end

  resource :dashboard

  namespace :sessions do
    resources :organizations
    resources :delivery_schedules
  end

  resources :products, only: [:index]
  resources :markets, only: [:index]
  resources :sellers, only: [:index, :show]

  root to: redirect('/dashboard')
end
