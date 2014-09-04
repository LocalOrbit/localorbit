Rails.application.routes.draw do
  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}app.#{Figaro.env.domain}/#{params[:path]}"
    }

  devise_for :users, skip: [:registrations]
  devise_scope :user do
    get "account" => "devise/registrations#edit", as: :edit_user_registration
    put "account" => "devise/registrations#update", as: :user_registration
  end
  resource :registration do
    get "terms-of-service" => "registrations#terms_of_service"
    get "standards" => "registrations#standards"
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

    resources :labels, only: [:index, :show]

    get "financials" => "financials#index"
    namespace :financials do
      resource  :overview, only: [:show]
      resource  :offline_payment, only: [:show, :create]
      resources :payments, only: [:index]
      resources :invoices do
        collection do
          post :resend
          post :resend_overdue
        end
      end
      resources :receipts, only: [:index, :edit, :update]
      resources :vendor_payments
      resources :market_payments, only: [:index, :create]
      resources :service_payments, only: [:index, :create]
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

      member do
        get :delivery_schedules
        get :market_memberships
        get :available_inventory
        patch :update_active
      end
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

    resources :users, only: [:index, :edit, :update] do
      patch :update_enabled, on: :member
    end

    resources :promotions do
      member do
        get :activate
        get :deactivate
      end
    end

    resources :discounts

    resource :fresh_sheet, only: [:show, :update, :create] do
      get :preview
    end
    resources :newsletters

    resources :invoices, only: :show do
      member do
        get "invoice" => "invoices#show"
        get "mark-invoiced" => "invoices#mark_invoiced"
        get :pdf, to: "invoices#show_pdf"
      end
    end

    resources :activities, only: :index
    resources :categories, only: [:index, :show, :new, :create], path: :taxonomy
    resource :unit_request, only: :create
    resource :category_request, only: :create

    resources :reports, only: [:index, :show]
    resources :metrics, only: [:index, :show] do
      collection do
        get "map" => "metrics#map"
      end
    end
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

  root to: redirect("/users/sign_in")
end
