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

  def self.ensure_user_has_subscription_link_to(user, subscription_type_keyword:)
    if user.subscription_types.where(keyword: subscription_type_keyword).count == 0
      if sub_type = SubscriptionType.find_by(keyword: subscription_type_keyword)
        user.subscription_types << sub_type
      end
    end
    nil
  end

  def self.ensure_user_has_subscription_links_to_fresh_sheet_and_newsletter(user)
    [ SubscriptionType::Keywords::FreshSheet,
      SubscriptionType::Keywords::Newsletter 
    ].each do |keyword|
      Subscription.ensure_user_has_subscription_link_to(user, subscription_type_keyword: keyword)
    end
    nil
  end
end
