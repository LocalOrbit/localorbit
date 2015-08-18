Rails.application.routes.draw do

  mount StripeEvent::Engine, at: '/webhooks/stripe'

  get 'style_guide/index'

  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}app.#{Figaro.env.domain}/#{params[:path]}"
    }

  devise_for :users, skip: [:registrations]
  devise_scope :user do
    get "account" => "devise/registrations#edit", as: :edit_user_registration
    put "account" => "devise/registrations#update", as: :user_registration
  end

  get "zendesk/sso" => "zendesk_sso#show"

  concern :bank_account do
    resources :bank_accounts, only: [:index, :new, :create, :destroy] do
      resource :bank_account_verification, only: [:show, :update], path: :verify
    end
  end

  concern :activatable do
    member do
      patch :update_active
    end
  end


  # Hoping that this is the embryo of a RESTful API for future development in
  # the app, especially LocalEyes features.
  namespace :api do
    namespace :v1 do
      resources :products, only: [:index]
      resources :filters, only: [:index]
    end
  end

  namespace :admin do
    resources :markets, concerns: [:bank_account, :activatable], except: [:edit] do
      resources :market_addresses,   as: :addresses,  path: :addresses
      resources :market_managers,    as: :managers,   path: :managers
      resources :delivery_schedules, path: :deliveries
      resource  :fees, only: [:show, :update]
      resource  :style_chooser, controller: :style_chooser, only: [:show, :update]
      resource  :cross_sell, controller: :market_cross_sells, only: [:show, :update]
      resources :deposit_accounts, only: [:index, :new, :create, :destroy]
      get :payment_options
    end

    resources :labels, only: [:index, :show]

    get "upload" => "upload#index"

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
      resources :batch_invoices, only: [:show] do
        member do
          get :progress
        end
      end
      resources :receipts, only: [:index, :edit, :update]
      resources :vendor_payments

      scope path: :admin do
        resources :market_payments,  only: [:index, :create]
        resources :automate_market_payments,  only: [:index, :create]
        resources :service_payments, only: [:index, :create]
        resources :lo_payments,      only: [:index, :create]
        resources :automate_seller_payments,  only: [:index, :create]
      end
    end

    resources :orders, only: [:index, :show, :update] do
      resources :table_tents_and_posters, :controller=>"/table_tents_and_posters", only: [:index, :show, :create]
    end

    resources :organizations, concerns: [:bank_account, :activatable] do
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
      end
    end

    resource :delivery_tools, only: :show do
      resources :pick_lists, only: :show
      resources :pack_lists, only: :show
      resources :individual_pack_lists, only: :show
      resources :order_summaries, only: :show
      resources :deliveries do
        resources :packing_labels, :controller=>"/deliveries/packing_labels", only: [:show, :index]
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
        get :await_pdf, to: "invoices#await_pdf"
        get :peek, to: "invoices#peek"
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

  resource :subscriptions do
    get "unsubscribe" => "subscriptions#unsubscribe"
    get "confirm_unsubscribe" => "subscriptions#confirm_unsubscribe"
  end

  get '/products/search' => "products#search"
  resources :products, only: [:index, :show] do
    get '/row' => "products#render_product_row"
  end
  resources :organizations, only: :index
  resource  :market, only: [:show]
  resources :sellers, only: [:index, :show]
  resource :cart, only: [:update, :show, :destroy]
  resources :orders, only: [:show, :create] do
    resources :table_tents_and_posters, :controller=>"table_tents_and_posters", only: [:index, :show, :create]
  end
  resource :registration, only: [:show, :create]

  get "/pdf_view/header", to: "pdf_view#header"

  if Rails.env.development?
    get "dev/pdf(/:action)", to: "dev/pdf", as: "dev_pdf"
  end


  get "o/:id", to: "qr_code#order", as: "qr_code"

  get "pdf_tester", to: "pdf_tester#index", as: "pdf_tester"
  post "pdf_tester/generate", to: "pdf_tester#generate", as: "pdf_tester_generate"


  root to: redirect("/users/sign_in")
end
