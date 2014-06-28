class MarketOrganization < ActiveRecord::Base
  include SoftDelete

  belongs_to :market
  belongs_to :organization

  after_update :check_for_orphaned_users

  private

  def check_for_orphaned_users
    if organization.markets.empty?
      organization.users.destroy_all
    end
  end
end
