class Subscription < ActiveRecord::Base
  include SoftDelete

  belongs_to :user
  belongs_to :subscription_type

  before_create do |sub|
    sub.token = SecureRandom.hex(32).upcase
  end
end
