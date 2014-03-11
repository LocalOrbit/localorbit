Rails.application.routes.draw do
  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}#{Figaro.env.domain}/#{params[:path]}"
    }

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
      resources :bank_accounts, only: [:index, :new, :create]
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
    resources :deliveries
  end

  resources :products, only: [:index]
  resource  :market, only: [:show]
  resources :sellers, only: [:index, :show]
  resource :cart, only: [:update]

  root to: redirect('/dashboard')
end
