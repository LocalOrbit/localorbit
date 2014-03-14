FactoryGirl.define do
  factory :market do
    sequence(:name)      {|n| "Market #{n}" }
    sequence(:subdomain) {|n| "market-#{n}" }
    timezone      'US/Eastern'
    contact_name  'Jill Smith'
    contact_email 'jill@smith.com'
    contact_phone '616-222-2222'
    policies      'Do no harm...'
    profile       'Market profile...'

    trait :with_addresses do
      after(:create) { |m| create_list(:market_address, 2, market: m) }
    end

    trait :with_delivery_schedule do
      after(:create) do |m|
        create(:delivery_schedule, market: m)
      end
    end
  end

  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    password "password"
    password_confirmation "password"
    role 'user'

    trait :market_manager do
      role 'user'
      after(:create) do |user|
        m = create(:market)
        user.managed_markets << m
      end
    end

    trait :admin do
      role 'admin'
    end
  end

  factory :order do
    sequence(:order_number) {|n| "LO-#{n}"}
    placed_at        Time.current

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
    delivery_status  "Pending"

    delivery_fees    0.00
    delivery_id      0

    payment_method   "Purchase Order"
    payment_status   "Unpaid"

    total_cost       100.99
  end

  factory :order_item do
    sequence(:name) {|n| "Order Item #{n}"}
    seller_name "Old McDonald"
    quantity    1
    unit        "per box"
    unit_price  6.99
  end

  factory :organization do
    sequence(:name) {|n| "Organization #{n}" }
    can_sell true

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
        create_list(:location, 2, organization: org)
      end
    end
  end

  factory :product do
    sequence(:name) {|n| "Product #{n}" }
    category { Category.find_by(name: "Empire Apples") }
    short_description "Empire state of mind"

    # We need to set this in the factory because FactoryGirl doesn't trigger before_save
    top_level_category { category.top_level_category }
    organization

    trait :decorated do
      initialize_with do
        ProductDecorator.new(new)
      end
    end

    trait :sellable do
      after(:create) do |product|
        create(:price, product: product)
        create(:lot, product: product)
      end
    end
  end

  factory :lot do
    product
    quantity 15

    trait :with_expiration do
      sequence(:number) {|n| "lot-#{n}"}
      good_from Time.current
      expires_at 1.week.from_now
    end
  end

  factory :price do
    product
    min_quantity 1
    sale_price 3.00
  end

  factory :category do
    sequence(:name) {|n| "Category #{n}" }
  end

  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    address "500 S. State Street"
    city "Ann Arbor"
    state "MI"
    zip "48109"
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

  factory :market_address do
    sequence(:name) {|n| "Location #{n}" }
    address "500 S. State Street"
    city "Ann Arbor"
    state "MI"
    zip "48109"
  end

  factory :delivery_schedule do
    day 2
    order_cutoff 6
    seller_fulfillment_location_id 0
    seller_delivery_start '7:00 AM'
    seller_delivery_end   '11:00 AM'
    association :market, factory: [:market, :with_addresses]

    trait :buyer_pickup do
      seller_fulfillment_location { market.addresses.first }
      buyer_pickup_start '10:00 AM'
      buyer_pickup_end '12:00 PM'
      buyer_pickup_location { market.addresses.first }
    end
  end

  factory :delivery do
    delivery_schedule
    deliver_on Date.today
  end
end
