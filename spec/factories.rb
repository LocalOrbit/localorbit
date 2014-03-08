FactoryGirl.define do
  factory :market do
    sequence(:name)      {|n| "Market #{n}" }
    sequence(:subdomain) {|n| "market-#{n}" }
    timezone      'EST'
    contact_name  'Jill Smith'
    contact_email 'jill@smith.com'
    contact_phone '616-222-2222'
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

  factory :organization do
    sequence(:name) {|n| "Organization #{n}" }
    can_sell true

    trait :seller do
      can_sell true
    end

    trait :buyer do
      can_sell false
    end
  end

  factory :product do
    sequence(:name) {|n| "Product #{n}" }
    category { Category.find_by(name: "Empire Apples") }

    # We need to set this in the factory because FactoryGirl doesn't trigger before_save
    top_level_category { category.top_level_category }
    organization

    trait :decorated do
      initialize_with do
        ProductDecorator.new(new)
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
  end
end
