class ManagedMarket < ActiveRecord::Base
  belongs_to :market
  belongs_to :user
end
