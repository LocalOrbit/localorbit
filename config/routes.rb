Rails.application.routes.draw do

  devise_for :users

  namespace :admin do
    resources :markets do
      resources :market_addresses, as: :addresses, path: :addresses
      resources :market_managers, as: :managers, path: :managers
    end

    resources :organizations do
      resources :users
      resources :locations, except: :destroy do
        collection do
          delete :destroy
          put :update_defaults, as: :update_default
        end
      end
    end

    resources :products do
      resources :lots
      resources :prices
    end
  end

  resource :dashboard

  resources :organizations, only: [] do
    resources :locations, only: [:index]
  end

  resources :products, only: [:index]

  root to: redirect('/dashboard')
end
