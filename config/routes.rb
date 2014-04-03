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
        resource :bank_account_verification, only: [:show, :update], path: :verify
      end
    end

    get "financials" => "financials#index"
    namespace :financials do
      resources :orders
    end

    resources :organizations do
      resources :bank_accounts, only: [:index, :new, :create] do
        resource :bank_account_verification, only: [:show, :update], path: :verify
      end
      resources :organization_users, as: :users, path: :users
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

    resource :fresh_sheet, only: [:show, :update] do
      get :preview
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

  resources :products, only: [:index, :show]
  resource  :market, only: [:show]
  resources :sellers, only: [:index, :show]
  resource :cart, only: [:update, :show, :destroy]
  resource :orders

  root to: redirect('/dashboard')
end
