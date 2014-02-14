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
    organization

    trait :decorated do
      initialize_with do
        ProductDecorator.new(new)
      end
    end
  end

  factory :location do
    sequence(:name) {|n| "Location #{n}" }
    address "500 S. State Street"
    city "Ann Arbor"
    state "Michigan"
    zip "48109"

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
end
