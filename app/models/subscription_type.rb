class SubscriptionType < ActiveRecord::Base
  module Keywords
    FreshSheet = "fresh_sheet"
    Newsletter = "newsletter"
  end

  has_many :subscriptions
  has_many :users, through: :subscriptions
end
