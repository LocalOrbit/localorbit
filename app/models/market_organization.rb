class MarketOrganization < ActiveRecord::Base
  include SoftDelete

  belongs_to :market
  belongs_to :organization
end
