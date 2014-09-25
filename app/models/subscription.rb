class Subscription < ActiveRecord::Base
  include SoftDelete

  belongs_to :user
  belongs_to :subscription_type

  before_create do |sub|
    sub.token = SecureRandom.hex(32).upcase
  end

  def self.unsubscribe_by_token(token)
    if token and subscription = Subscription.find_by(token: token)
      return subscription.soft_delete
    else
      return false
    end
  end
end
