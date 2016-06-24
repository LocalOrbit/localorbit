FactoryGirl.define do
  factory :bank_account do
    association :bankable, factory: :market

    # Default as CC account:
    bank_name        "Visa"
    account_type     "visa"
    sequence(:last_four) {|n| "#{'%04d' % n}"}
    expiration_month 5
    expiration_year  2020

    trait :credit_card do
      # bank_accounts now default to CC stuff
    end

    trait :checking do
      bank_name        "LMCU"
      account_type     "checking"
      sequence(:last_four) {|n| "#{'%04d' % n}"}
      expiration_month nil # do not want
      expiration_year nil  # do not want
    end

    trait :savings do
      bank_name        "LMCU"
      account_type     "savings"
      sequence(:last_four) {|n| "#{'%04d' % n}"}
      expiration_month nil # do not want
      expiration_year nil  # do not want
    end

    trait :verified do
      verified true
    end
  end

  factory :cart do
    organization
    market
    delivery
    user

    trait :with_items do
      after(:create) do |cart|
        create_list(:cart_item, 2, cart: cart)
      end
    end
  end

  factory :credit do
    order
    user
    amount_type "fixed"
    amount 1.50
    apply_to "total"
    payer_type "market"
    paying_org_id nil
    notes "Bad on delivery."
  end

  factory :order_template do
    sequence(:name) {|n| "Cart #{n}"}
    market
  end

  factory :order_template_item do
    product { create(:product, :sellable) }
    order_template
    quantity 1
  end

  factory :cart_item do
    product { create(:product, :sellable) }
    cart
    quantity 1
  end

  factory :category do
    sequence(:name) {|n| "Category #{n}" }
  end

  factory :delivery do
    delivery_schedule
    deliver_on Date.today
    buyer_deliver_on { deliver_on }
  end

  factory :delivery_schedule do
    day 2
    order_cutoff 6
    seller_fulfillment_location_id 0
    seller_delivery_start "7:00 AM"
    seller_delivery_end "11:00 AM"
    buyer_pickup_start "12:00 AM"
    buyer_pickup_end "12:00 AM"
    association :market, factory: [:market, :with_addresses]

    trait :direct_to_customer do
      # this is currently the same as the above defaults
    end

    trait :hub_to_buyer do
      seller_fulfillment_location { market.addresses.first }
      buyer_pickup_start "10:00 AM"
      buyer_pickup_end "12:00 PM"
      buyer_pickup_location_id 0
    end

    trait :buyer_pickup do
      seller_fulfillment_location { market.addresses.first }
      buyer_pickup_start "10:00 AM"
      buyer_pickup_end "12:00 PM"
      buyer_pickup_location { market.addresses.first }
    end

    trait :fixed_fee do
      fee_type "fixed"
      fee 1.00
    end

    trait :percent_fee do
      fee_type "percent"
      fee 25
    end
  end

  factory :discount do
    sequence(:name) {|n| "Discount ##{n}" }
    sequence(:code) {|n| n.to_s(16) }
    type "fixed"
    discount 5.00
    maximum_uses 0
    maximum_organization_uses 0
  end

  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    sequence(:address) {|n| "#{n} S. State Street" }
    city "Ann Arbor"
    state "MI"
    zip "48109"
    sequence(:phone) {|n| "(616) 555-#{"%04d" % n}" }
    organization

    trait :default_billing do
      default_billing true
    end

    trait :default_shipping do
      default_shipping true
    end

    trait :decorated do
      initialize_with do
        LocationDecorator.new(new)
      end
    end
  end

  factory :lot do
    product
    quantity 150

    trait :with_expiration do
      sequence(:number) {|n| "lot-#{n}" }
      good_from Time.current
      expires_at 1.week.from_now
    end
  end

  factory :market do
    payment_provider       'stripe'
    active               true
    sequence(:name)      {|n| "Market #{n}" }
    sequence(:subdomain) {|n| "market#{n}" }
    tagline                'Connecting Farm to Market'
    timezone               'US/Eastern'
    contact_name           'Jill Smith'
    contact_email          'jill@smith.com'
    contact_phone          '616-222-2222'
    policies               'Do no harm...'
    profile                'Market profile...'
    local_orbit_seller_fee 2
    local_orbit_market_fee 0
    market_seller_fee      1
    credit_card_seller_fee 1
    credit_card_market_fee 0
    ach_seller_fee         1.3
    ach_market_fee         0
    ach_fee_cap            8
    allow_purchase_orders  true
    allow_credit_cards     true
    default_allow_purchase_orders   false
    default_allow_credit_cards      true
    auto_activate_organizations     false
    product_label_format 4
    print_multiple_labels_per_item false
    alternative_order_page         false
    stripe_standalone              false
    allow_product_fee              false
    number_format_numeric 0
    organization           {create(:organization, :market)}

    trait :with_address do
      after(:create) {|m| create(:market_address, market: m) }
    end

    trait :with_addresses do
      after(:create) {|m| create_list(:market_address, 2, market: m) }
    end

    trait :with_delivery_schedule do
      after(:create) do |m|
        create(:delivery_schedule, market: m)
      end
    end

    trait :with_logo do
      logo File.open(Rails.root.join("app/assets/images/logo-farm-to-fork.png"))
    end

    trait :with_category_fee do
      after(:create) do |m|
        create(:category_fee, market: m)
      end

    end
  end

  factory :market_address do
    market
    sequence(:name) {|n| "Market Address #{n}" }
    address "44 E. 8th St"
    city "Holland"
    state "MI"
    zip "49423"
    phone "(616) 555-1212"
  end

  factory :market_organization do
    market
    organization
  end

  factory :category_fee do
    market
    category { Category.find_by(name: "Apples") }
    fee_pct 12
  end

  factory :newsletter do
    subject "Some News"
    header "Some Exciting News"
    body "news goes here"
    market
    trait :buyers do
      header "Exciting news for Buyers"
      subject "Buyer's News!"
      body "This one goes out to the Buyers."
      buyers true
    end
    trait :sellers do
      header "Exciting news for Sellers"
      subject "Seller's News!"
      body "This one goes out to the Sellers."
      sellers true
    end
    trait :market_managers do
      header "Exciting news for Market Managers"
      subject "Manager's News!"
      body "This one goes out to the Market Managers."
      market_managers true
    end
    trait :everyone do
      market_managers true
      sellers true
      buyers true
    end
  end

  factory :order do
    organization
    market
    delivery
    payment_provider 'balanced'

    sequence(:order_number) {|n| "LO-%s-%s-%07d" % [Time.now.strftime("%y"), market.try(:subdomain).to_s.upcase, n] }
    placed_at        { Time.current }

    billing_organization_name "Collective Idea"
    billing_address  "44 E. 8th St"
    billing_city     "Holland"
    billing_state    "Michigan"
    billing_zip      "49423"
    billing_phone    "(616) 555-1212"

    delivery_address "123 Main"
    delivery_city    "Holland"
    delivery_state   "Michigan"
    delivery_zip     "49423"
    delivery_phone   "(616) 555-1222"

    delivery_fees    0.001

    payment_method   "purchase order"
    payment_status   "unpaid"

    total_cost       100.99

    trait :with_items do
      before(:create) do |order|
        order.items = create_list(:order_item, 1, product: create(:product, :sellable))
      end
    end
  end

  factory :order_item do
    product factory: [:product, :sellable]
    sequence(:name) {|n| product.name || "Order Item #{n}"}
    seller_name         "Old McDonald"
    quantity            1
    unit                "per box"
    unit_price          6.99
    delivery_status     "pending"
    discount_market     0.0
    discount_seller     0.0
    product_fee_pct     0.0

    trait :delivered do
      delivery_status "delivered"
    end
  end

  factory :order_item_lot do
    quantity 1
  end

  factory :organization do
    sequence(:name) {|n| "Organization #{n}" }
    can_sell true
    show_profile true
    allow_purchase_orders true
    allow_credit_cards    true
    allow_ach             true
    display_twitter       false
    display_facebook      false
    active                true

    trait :admin do
      org_type 'A'
    end

    trait :market do
      plan                { create(:plan, :grow) }
      org_type 'M'
    end

    trait :seller do
      can_sell true
      org_type 'S'
    end

    trait :buyer do
      can_sell false
      org_type 'B'
    end

    trait :single_location do
      after(:create) do |org|
        create(:location, organization: org)
      end
    end

    trait :multiple_locations do
      after(:create) do |org|
        create(:location, organization: org)
        create(:location, organization: org)
      end
    end
  end

  factory :payment do
    payee          { Organization.first }
    payment_type   "order"
    payment_method "purchase order"
    amount         199.99
    status         "paid"
    payment_provider 'balanced'

    trait :checking do
      payment_type   "order"
      payment_method "ach"
      status         "pending"
    end

    trait :credit_card do
      payment_type   "order"
      payment_method "credit card"
    end

    trait :market_orders do
      payment_type "market payment"
    end

    trait :service do
      payee          nil
      payment_type   "service"
      payment_method "ach"
    end
  end

  factory :plan do
    sequence(:name) {|n| "Plan ##{n}" }

    discount_codes     true
    cross_selling      true
    custom_branding    true
    automatic_payments true
    advanced_pricing   true
    advanced_inventory true
    promotions         true
    order_printables   true
    packing_labels     true
    sellers_edit_orders true

    trait :nothing do
      name "Start Up"
      discount_codes     false
      cross_selling      false
      custom_branding    false
      automatic_payments false
      advanced_pricing   false
      advanced_inventory false
      promotions         false
      order_printables   false
      packing_labels     false
      sellers_edit_orders false
    end

    trait :start_up do
      name "Start Up"
      discount_codes     false
      cross_selling      false
      custom_branding    false
      automatic_payments false
      advanced_pricing   false #this is true in the real world
      advanced_inventory false
      promotions         false
      order_printables   false
      packing_labels     false
      sellers_edit_orders false
    end

    trait :grow do
      name "Grow"
      discount_codes     true
      cross_selling      true
      custom_branding    true
      automatic_payments true
      advanced_pricing   true
      advanced_inventory true
      promotions         true
      order_printables   true
      packing_labels     true
      sellers_edit_orders     true
    end

    trait :automate do
      name "Automate"
      discount_codes     true
      cross_selling      true
      custom_branding    true
      automatic_payments true
      advanced_pricing   true
      advanced_inventory true
      promotions         true
      order_printables   true
      packing_labels     true
      sellers_edit_orders     true
    end

    trait :localeyes do
      name "LocalEyes"
      discount_codes     true
      cross_selling      true
      custom_branding    true
      automatic_payments false
      advanced_pricing   false
      advanced_inventory false
      promotions         false
      order_printables   true
      packing_labels     true
      sellers_edit_orders     false
      has_procurement_managers true
    end
  end

  factory :price do
    product
    min_quantity 1
    sale_price 3.00
    product_fee_pct 0.0

    trait :past_price do
      after(:create) do |price|
        price.update_column(:updated_at, DateTime.now - 100.years)
        price.update_column(:created_at, DateTime.now - 100.years)
      end
    end
  end

  factory :product do
    sequence(:name) {|n| "Product #{n}" }
    category { Category.find_by(name: "Apples") }
    short_description "Apples"

    # We need to set this in the factory because FactoryGirl doesn't trigger before_save
    top_level_category { category.top_level_category }
    organization
    unit { Unit.first || create(:unit) }

    trait :decorated do
      initialize_with do
        ProductDecorator.new(new)
      end
    end

    trait :sellable do
      after(:create) do |product|
        create(:price, :past_price, product: product)
        create(:lot, product: product) if product.lots.empty?
      end
    end
  end

  factory :external_product do
    product { create(:product, :sellable) }
    organization { product.organization }
    sequence(:contrived_key) {|n| "contrivedkey#{n}"}
  end

  factory :promotion do
    market
    product
    sequence(:name) {|n| "Featured Promotion ##{n}" }
    sequence(:title) {|n| "Featured Promotion Title ##{n}" }
    active false

    trait :active do
      active true
    end
  end

  factory :sequence do
    name "stuff"
    value 0
  end

  factory :unit do
    singular "box"
    plural   "boxes"
  end

  factory :role do

    trait :admin do
      org_type 'A'
      name 'Admin'
      activities '{product:index,organization_cross_selling:index,user:index,role:index,market_cross_selling:index,order:index,metric:index,unit:index,event:index,taxonomy:index,internal_financial:index,financial:index,market_profile:index,market_manager:index,delivery:index,order_item:index,market_address:index,market_deliveries:index,market_payment_methods:index,market_deposit_accounts:index,market_fees:index,template:index,market_custom_branding:index,market:index,send_invoices:index,payment_history:index,organization:index,delivery_schedule:index,enter_receipts:index,record_payments:index,product:index,fresh_sheet:index,newsletter:index,promotion:index,discount_code:index,sent_email:index,dashboard:index,email_test:index,report:index,referral:index,}'
    end

    trait :market_manager do
      org_type 'M'
      name 'Market Manager'
      activities '{market_cross_selling:index,order:index,financial:index,market_profile:index,market_manager:index,delivery:index,order_item:index,market_address:index,market_deliveries:index,market_payment_methods:index,market_deposit_accounts:index,template:index,market_custom_branding:index,market:index,send_invoices:index,payment_history:index,organization:index,delivery_schedule:index,financial_overview:index,enter_receipts:index,record_payments:index,product:index,fresh_sheet:index,newsletter:index,promotion:index,all_supplier:index,discount_code:index,dashboard:index,report:index}'
    end

    trait :buyer do
      org_type 'B'
      name 'Buyer'
      activities '{payment_history:index, purchase_history:index,purchase_history:index,financial:index,market:index,financial_overview:index,all_supplier:index,dashboard:index,review_invoices:index,report:index}'
    end

    trait :supplier do
      org_type 'S'
      name 'Supplier'
      activities '{organization_cross_selling:index,payment_history:index,delivery_schedule:index,product:index,dashboard:index,financial:index,order:index,delivery:index,order_item:index,fresh_sheet:index,newsletter:index,promotion:index,discount_code:index,report:index}'
    end

    trait :start_up_plan do
      org_type 'M'
      name 'Market Manager'
      activities '{startup_plan:index,order:index,financial:index,market_profile:index,market_manager:index,delivery:index,order_item:index,market_address:index,market_deliveries:index,market_payment_methods:index,market_deposit_accounts:index,template:index,market:index,send_invoices:index,payment_history:index,organization:index,delivery_schedule:index,financial_overview:index,enter_receipts:index,record_payments:index,product:index,fresh_sheet:index,newsletter:index,all_supplier:index,dashboard:index,report:index}'
    end

    trait :grow_plan do
      org_type 'M'
      name 'Market Manager'
      activities '{market_cross_selling:index,order:index,financial:index,market_profile:index,market_manager:index,delivery:index,order_item:index,market_address:index,market_deliveries:index,market_payment_methods:index,market_deposit_accounts:index,template:index,market_custom_branding:index,market:index,send_invoices:index,payment_history:index,organization:index,delivery_schedule:index,financial_overview:index,enter_receipts:index,record_payments:index,product:index,fresh_sheet:index,newsletter:index,promotion:index,all_supplier:index,discount_code:index,dashboard:index,report:index}'
    end
  end

  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    password "password"
    password_confirmation "password"
    #role "user"
    confirmed_at { Time.current }

    trait :market_manager do
      #role "user"
      roles {[FactoryGirl.create(:role, :market_manager)]}

      after(:create) do |user|
        if user.managed_markets.empty?
          m = create(:market)
          user.managed_markets << m
        end
        if user.organizations.empty?
          o = create(:organization, :market)
          user.organizations << o
        end
      end
    end

    trait :admin do
      #role "admin"
      roles {[FactoryGirl.create(:role, :admin)]}
      after(:create) do |user|
        if user.organizations.empty?
          o = create(:organization, :admin)
          user.organizations << o
        end
      end
    end

    trait :supplier do
      roles {[FactoryGirl.create(:role, :supplier)]}
      after(:create) do |user|
        #m = create(:market)
        if user.organizations.empty?
          o = create(:organization, :seller)
          user.organizations << o
        end
      end
    end

    trait :buyer do
      roles {[FactoryGirl.create(:role, :buyer)]}
      after(:create) do |user|
        #m = create :market
        if user.organizations.empty?
          o = create(:organization, :buyer)
          user.organizations << o
        end
      end
    end
  end

  factory :user_with_role, :parent => :user do
    role {[FactoryGirl.create(:role, :market_manager)]}
  end

  factory :subscription do
    user
    subscription_type
  end

  factory :subscription_type do
    sequence(:name) {|n| "Subscription Type #{n}" }
    sequence(:keyword) {|n| "subtype_#{n}" }

    trait :fresh_sheet do
      name "Fresh Sheet (testing)"
      keyword SubscriptionType::Keywords::FreshSheet
    end

    trait :newsletter do
      name "Newsletter (testing)"
      keyword SubscriptionType::Keywords::Newsletter
    end
  end

  factory :fresh_sheet do
    user
    market
    note "This is a note to go with the Fresh Sheet."
  end

  factory :batch_invoice do
    user
  end

  factory :batch_invoice_error do

  end

  factory :order_printable do
    user
    order
    include_product_names false
    printable_type "table tent"
  end

  factory :packing_labels_printable do
    user
    delivery
  end
end
