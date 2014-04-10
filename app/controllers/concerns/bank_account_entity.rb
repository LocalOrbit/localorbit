module BankAccountEntity
  extend ActiveSupport::Concern

  included do
    before_action :load_entity
  end

  private

  def load_entity
    @entity = params[:market_id].present? ? find_market : find_organization
  end

  def find_market
    if current_user.admin?
      current_user.markets.find(params[:market_id])
    else
      current_user.managed_markets.find(params[:market_id])
    end
  end

  def find_organization
    current_user.managed_organizations.find(params[:organization_id])
  end
end
