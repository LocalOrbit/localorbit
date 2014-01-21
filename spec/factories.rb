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
    role 'admin'

    trait :market_manager do
      role 'user'
      after(:create) do |user|
        m = create(:market)
        user.managed_markets << m
      end
    end
  end

  factory :organization do
    sequence(:name) {|n| "Organization #{n}" }
    can_sell false

    trait :seller do
      can_sell true
    end
  end
end