class SubscriptionType < ActiveRecord::Base
  module Keywords
    FRESHSHEET = 'fresh_sheet'
    NEWSLETTER = 'newsletter'
  end

  has_many :subscriptions
  has_many :users, through: :subscriptions
end
