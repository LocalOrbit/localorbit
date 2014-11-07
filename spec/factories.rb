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
    plan
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
    credit_card_seller_fee 3
    credit_card_market_fee 0
    ach_seller_fee         1.3
    ach_market_fee         0
    ach_fee_cap            8
    allow_purchase_orders  true
    allow_credit_cards     true
    default_allow_purchase_orders false
    default_allow_credit_cards    true
    auto_activate_organizations   false

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

    delivery_fees    0.00

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

    trait :seller do
      can_sell true
    end

    trait :buyer do
      can_sell false
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
    payee          { Market.first }
    payment_type   "order"
    payment_method "purchase order"
    amount         199.99
    status         "paid"

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
  end

  factory :price do
    product
    min_quantity 1
    sale_price 3.00
  end

  factory :product do
    sequence(:name) {|n| "Product #{n}" }
    category { Category.find_by(name: "Empire Apples") }
    short_description "Empire state of mind"

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
        create(:price, product: product)
        create(:lot, product: product) if product.lots.empty?
      end
    end
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

  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    password "password"
    password_confirmation "password"
    role "user"
    confirmed_at { Time.current }

    trait :market_manager do
      role "user"
      after(:create) do |user|
        if user.managed_markets.empty?
          m = create(:market)
          user.managed_markets << m
        end
      end
    end

    trait :admin do
      role "admin"
    end

    trait :seller do
      after(:create) do |user|
        m = create(:market)
        o = create(:organization, :seller, markets: [m])
        user.organizations << o
      end
    end
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
end
