Rails.application.routes.draw do
  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}#{Figaro.env.domain}/#{params[:path]}"
    }

  devise_for :users, skip: [:registrations]
  devise_scope :user do
    get 'account' => 'devise/registrations#edit', as: :edit_user_registration
    put 'account' => 'devise/registrations#update', as: :user_registration
  end

  namespace :admin do
    resources :markets do
      resources :market_addresses,   as: :addresses,  path: :addresses
      resources :market_managers,    as: :managers,   path: :managers
      resources :delivery_schedules, path: :deliveries
      resource  :fees, only: [:show, :update]
      resources :bank_accounts, only: [:index, :new, :create] do
        get "verify"
        put "verify" => "bank_accounts#verification"
      end
    end

    get "financials" => "financials#index"
    namespace :financials do
      resources :orders
    end

    resources :organizations do
      resources :users
      resources :bank_accounts, only: [:index, :new, :create] do
        get "verify"
        put "verify" => "bank_accounts#verification"
      end
      resources :locations, except: :destroy do
        collection do
          delete :destroy
          put :update_default
        end
      end
    end

    resources :products do
      resources :lots
      resources :prices do
        collection do
          delete :destroy
        end
      end
    end

    resource :unit_request, only: :create
    resource :category_request, only: :create
  end

  resource :dashboard do
    get "/coming_soon" => "dashboards#coming_soon"
  end

  namespace :sessions do
    resources :organizations
    resources :deliveries
  end

  resources :products, only: [:index]
  resource  :market, only: [:show]
  resources :sellers, only: [:index, :show]
  resource :cart, only: [:update, :show]
  resource :orders

  root to: redirect('/dashboard')
end
