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
    Market.managed_by(current_user).find(params[:market_id])
  end

  def find_organization
    current_user.managed_organizations.find(params[:organization_id])
  end
end
