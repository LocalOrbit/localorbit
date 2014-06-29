Rails.application.routes.draw do
  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}app.#{Figaro.env.domain}/#{params[:path]}"
    }

  devise_for :users, skip: [:registrations]
  devise_scope :user do
    get 'account' => 'devise/registrations#edit', as: :edit_user_registration
    put 'account' => 'devise/registrations#update', as: :user_registration
  end
  get "zendesk/sso" => "zendesk_sso#show"

  concern :bank_account do
    resources :bank_accounts, only: [:index, :new, :create, :destroy] do
      resource :bank_account_verification, only: [:show, :update], path: :verify
    end
  end

  namespace :admin do
    resources :markets, concerns: :bank_account, except: [:edit] do
      resources :market_addresses,   as: :addresses,  path: :addresses
      resources :market_managers,    as: :managers,   path: :managers
      resources :delivery_schedules, path: :deliveries
      resource  :fees, only: [:show, :update]
      resource  :style_chooser, controller: :style_chooser, only: [:show, :update]
      resource  :cross_sell, controller: :market_cross_sells, only: [:show, :update]
      get :payment_options
    end

    get "financials" => "financials#index"
    namespace :financials do
      resource  :overview, only: [:show]
      resources :payments, only: [:index]
      resources :invoices
      resources :receipts, only: [:index, :edit, :update]
      resources :vendor_payments
      resources :market_payments, only: [:index, :create]
    end

    resources :orders, only: [:index, :show, :update]

    resources :organizations, concerns: :bank_account do
      resources :organization_users, as: :users, path: :users
      resource :cross_sell, controller: :organization_cross_sells, only: [:show, :update]
      resources :locations, except: :destroy do
        collection do
          delete :destroy
          put :update_default
        end
      end

      get :delivery_schedules, on: :member
      get :market_memberships, on: :member
    end

    resource :delivery_tools, only: :show do
      resources :pick_lists, only: :show
      resources :pack_lists, only: :show
      resources :individual_pack_lists, only: :show
      resources :order_summaries, only: :show
    end

    resources :products do
      resources :lots
      resources :prices do
        collection do
          delete :destroy
        end
      end
    end

    resources :order_items, only: :index, path: :sold_items do
      collection do
        post :set_status
      end
    end

    resources :users, only: :index

    resources :promotions do
      member do
        get :activate
        get :deactivate
      end
    end

    resource :fresh_sheet, only: [:show, :update] do
      get :preview
    end
    resources :newsletters

    resources :invoices, only: :show do
      member do
        get "invoice" => "invoices#show"
        get "mark-invoiced" => "invoices#mark_invoiced"
      end
    end

    resources :categories, only: :index, path: :taxonomy
    resource :unit_request, only: :create
    resource :category_request, only: :create

    get "reports"         => "reports#index"
    get "reports/:report" => "reports#show", as: :report
  end

  resource :dashboard do
    get "/coming_soon" => "dashboards#coming_soon"
  end

  namespace :sessions do
    resources :organizations
    resource :deliveries do
      get :reset
    end
  end

  resources :products, only: [:index, :show]
  resources :organizations, only: :index
  resource  :market, only: [:show]
  resources :sellers, only: [:index, :show]
  resource :cart, only: [:update, :show, :destroy]
  resources :orders, only: [:show, :create]
  resource :registration, only: [:show, :create]

  root to: redirect('/users/sign_in')
end
