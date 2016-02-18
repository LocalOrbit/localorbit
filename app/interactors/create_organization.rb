class CreateOrganization
  include Interactor

  def perform
    if respond_to?(:market_id) && market_id.blank?
      if organization_params(:can_sell)
        org_type = "S"
      else
        org_type = "B"
      end
      context[:organization] = Organization.new(organization_params.merge({:org_type => org_type}))
      organization.valid?
      organization.errors.add(:markets, :blank)
    elsif !respond_to?(:market_id) # Creating an organization for a Market
      organization_params = market_params.slice(:name,:allow_purchase_orders,:allow_credit_cards,:plan_id).merge({:org_type => "M"})
      context[:organization] = Organization.new(organization_params)
      if organization.valid?
        organization.save!
      end
    else
      market = user.markets.find(market_id)
      context[:organization] = market.organizations.create(organization_params)
    end

    fail! unless organization.errors.none?
  end
end
