Rails.application.routes.draw do

  mount StripeEvent::Engine, at: '/webhooks/stripe'

  resource :style_guide, only: :show, controller: :style_guide

  get '*path', constraints: NonMarketDomain.new, format: false,
    to: redirect {|params, request|
      "#{request.protocol}app.#{ENV.fetch('DOMAIN')}/#{params[:path]}"
    }

  devise_for :users, skip: [:registrations],
    controllers: {
      omniauth_callbacks: 'omniauth_callbacks',
      sessions: 'users/sessions'
    }
  devise_scope :user do
    get "account" => "devise/registrations#edit", as: :edit_user_registration
    put "account" => "devise/registrations#update", as: :user_registration
  end

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
          get :disconnect
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
      resources :markets, only: [] do
        resources :sellers, only: [] do
          resource :seller_payment_group, only: :show
        end
      end

      scope path: :admin do
        resources :market_payments,  only: [:index, :create]
        resources :automate_market_payments,  only: [:index, :create]
        resources :service_payments, only: [:index, :create]
        resources :lo_payments,      only: [:index, :create]
        resources :automate_seller_payments,  only: [:index, :create]
      end
    end

    resources :orders, only: [:index, :show, :update, :create, :destroy] do
      resources :table_tents_and_posters, :controller=>"/table_tents_and_posters", only: [:index, :show, :create]
      resources :order_items, only: [:show, :update] # for order price editing
      member do
        get :printable_show, to: "orders#printable_show"
        get :batch_printable_show, to: "orders#batch_printable_show"
        get :progress
      end
    end

    get "purchase_orders" => "orders#purchase_orders"
    resources :purchase_orders, only: [:show], :path => "purchase_order", :as => "purchase_order", :controller => 'orders'

    get "/sales_orders" => "orders#index", :path => "sales_orders", :as => "sales_orders"
    resources :sales_orders, only: [:show, :update, :create], :path => "sales_order", :as => "sales_order", :controller => 'orders'

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

      resources :pick_lists, param: :deliver_on, only: :show

      get "pick_list_date(/:deliver_on)", to: "pick_lists#show"

      resources :pack_lists, param: :deliver_on, only: :show

      get "pack_list_date(/:deliver_on)", to: "pack_lists#show"

      resources :individual_pack_lists, param: :deliver_on, only: :show

      get "individual_pack_list_date(/:deliver_on)", to: "individual_pack_lists#show"

      resources :order_summaries, param: :deliver_on, only: :show

      get "order_summary_date(/:deliver_on)", to: "order_summaries#show"

      resources :load_list, param: :deliver_on, only: :show

      resources :deliveries, param: :deliver_on do
        resources :packing_labels, :controller=>"/deliveries/packing_labels", only: [:show, :index]
        resources :individual_packing_labels, :controller=>"/deliveries/packing_labels", only: [:show, :index]
      end
    end

    # FIXME: For some reason the Rails 4.1 -> 4.2 upgrade didn't like our wonky way of adding a new
    # product ("unit") via the edit product form. It was sending a POST instead of an expected
    # PATCH, thus 404ing. edit_table.js.coffee is changing _method.
    post 'products/:id' => 'products#update'

    resources :products do
      resources :lots
      resources :prices do
        collection do
          delete :destroy
        end
      end
      collection do
        post :split
        post :undo_split
        get :update_supplier_products
      end
    end

    resources :consignment_transactions

    get "consignment_inventory" => "consignment_inventory#index"
    put "consignment_inventory" => "consignment_inventory#update"

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

    resources :batch_consignment_printables, only: :show do
      member do
        get :progress
      end
    end

    resources :activities, only: :index
    resources :categories, only: [:index, :show, :new, :create], path: :taxonomy
    resource :unit_request, only: :create
    resource :category_request, only: :create

    resources :reports, only: [:index, :show]

    resources :consignment_partial_po_report, only: [:show]
    resources :consignment_qb_report, only: [:show]

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

  get 'help' => 'help#show'

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

  get "/purchase_orders" => "orders#purchase_orders"
  resources :purchase_orders, only: [:show], :path => "purchase_order", :as => "purchase_order", :controller => 'orders'

  get "/sales_orders" => "orders#index", :path => "sales_orders", :as => "sales_orders"
  resources :sales_orders, only: [:show, :update, :create], :path => "sales_order", :as => "sales_order", :controller => 'orders'

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
