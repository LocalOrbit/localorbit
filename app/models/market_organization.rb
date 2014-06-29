class MarketOrganization < ActiveRecord::Base
  include SoftDelete

  belongs_to :market
  belongs_to :organization

  def after_soft_delete
    if organization.markets.empty?
      organization.users.destroy_all
    end
  end
end
