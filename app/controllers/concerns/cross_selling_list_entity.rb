module CrossSellingListEntity
  # KXM This is where we'll first leverage the move to Organizations.cross_selling_lists
  # Market works - Migrate code and modify load_entity to return the Organization.  Once
  # That works, all reference to '@entity' may be safely replaced by :organization
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
