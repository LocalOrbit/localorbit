Rails.application.routes.draw do

  mount StripeEvent::Engine, at: '/webhooks/stripe'

  # mount API::Base, at: "/"
  # mount API::GrapeSwaggerRails::Engine, at: "/documentation"

  get 'style_guide/index'

  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}app.#{Figaro.env.domain}/#{params[:path]}"
    }

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }, skip: [:registrations]
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

  concern :confirmable do
    member do
      patch :confirm_pending
    end
  end

  # Hoping that this is the embryo of a RESTful API for future development in
  # the app, especially LocalEyes features.
  namespace :api do
    namespace :v1 do
      resources :orders, only: [] do
        resources :credits, only: [:create]
      end
      resources :products, only: [:index]
      resources :filters, only: [:index]
      resources :order_templates, only: [:index, :create, :destroy]
      resources :dashboards, only: [:index]
    end
    # namespace :v2 do 
    #   resources :products
    # end
  end

  get "update_organizations" => "admin#update_organizations"

  namespace :admin do
    resources :markets, concerns: [:bank_account, :activatable, :confirmable], except: [:edit] do
      resources :market_addresses,   as: :addresses,  path: :addresses
      resources :market_managers,    as: :managers,   path: :managers
      resources :delivery_schedules, path: :deliveries, concerns: [:activatable]
      resource  :style_chooser, controller: :style_chooser, only: [:show, :update]
      resource  :cross_sell, controller: :market_cross_sells, only: [:show, :update]
      resources :cross_selling_lists do 
        collection do 
          get 'subscriptions' 
        end 
      end
      resource  :fees, only: [:show, :update]
      resources :category_fees, only: [:index, :new, :create, :destroy]
      resources :deposit_accounts, only: [:index, :new, :create, :destroy]
      resource  :stripe, controller: :market_stripe, only: [:show]
      resource :qb_profile, controller: :market_qb_profile do
        collection do
          get :authenticate
          get :oauth_callback
          get :sync
        end
      end
      resources :storage_locations, controller: :market_storage_locations
      get :payment_options
      patch :toggle_self_enabled_cross_sell
    end

    get "qlik" => "qlik#index"

    resources :roles

    resources :labels, only: [:index, :show]

    get "upload" => "upload#index"
    get "upload/download" => "upload#download"
    get "upload/export_products" => "upload#export_products"
    get "upload/get_documentation" => "upload#get_documentation"
    post "upload" => "upload#upload"

    post "upload/newjob" => "upload#newjob"

    get "financials" => "financials#index"
    namespace :financials do
      resource  :overview, only: [:show]
      resource  :offline_payment, only: [:show, :create]
      resources :payments, only: [:index, :update, :edit]
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
      resources :order_items, only: [:show, :update] # for order price editing
    end

    get "purchase_orders" => "orders#purchase_orders"

    resources :organizations, concerns: [:bank_account, :activatable] do
      resources :organization_users, as: :users, path: :users do
        get :invite
      end
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
        resources :individual_packing_labels, :controller=>"/deliveries/packing_labels", only: [:show, :index]
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

    resources :order_items, only: [:index, :update], path: :sold_items do
      collection do
        post :set_status
      end
    end

    resources :users, only: [:index, :edit, :update] do
      patch :update_enabled, on: :member
      get :confirm
      get :invite
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
    resources :suppliers
    resource :deliveries do
      get :reset
    end
  end

  resource :subscriptions do
    get "unsubscribe" => "subscriptions#unsubscribe"
    get "confirm_unsubscribe" => "subscriptions#confirm_unsubscribe"
  end

  resources :templates, :index do
    get '/new' => "templates#new"
  end

  resources :delivery_notes, only: [:new, :update, :edit, :show, :create, :destroy]
  post '/delivery_notes/new' => "delivery_notes#create"

  get '/products/search' => "products#search"
  get '/products/purchase' => "products#purchase"
  resources :products, only: [:index, :show] do
    get '/row' => "products#render_product_row"
  end
  resources :organizations, only: :index

  resource  :market, only: [:show]
  get '/markets/success(/:id)' => 'markets#success'
  resources :markets

  resource :roll_your_own_market, only: [] do
    post :get_stripe_coupon
    post :get_stripe_plans
    post :unique_subdomain
  end

  resources :sellers, only: [:index, :show]
  resource :cart, only: [:update, :show, :destroy]
  resources :orders, only: [:index, :show, :create] do
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
