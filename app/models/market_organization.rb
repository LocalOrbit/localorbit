class MarketOrganization < ActiveRecord::Base
  belongs_to :market
  belongs_to :organization

  after_destroy :check_for_orphaned_users

  private

  def check_for_orphaned_users
    if organization.markets.empty?
      organization.users.destroy_all
    end
  end
end
