class MarketOrganization < ActiveRecord::Base
  belongs_to :market
  belongs_to :organization
end
