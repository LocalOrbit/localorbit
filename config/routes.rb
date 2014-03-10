Rails.application.routes.draw do

  devise_for :users

  namespace :admin do
    resources :markets do
      resources :market_addresses,   as: :addresses,  path: :addresses
      resources :market_managers,    as: :managers,   path: :managers
      resources :delivery_schedules, path: :deliveries
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

  resources :organizations, only: [] do
    resources :locations, only: [:index]
  end

  resources :products, only: [:index]
  resources :markets, only: [:index]
  resources :sellers, only: [:index, :show]

  root to: redirect('/dashboard')
end
