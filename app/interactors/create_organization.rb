class CreateOrganization
  include Interactor

  def perform
    if market_id.blank?
      context[:organization] = Organization.new(organization_params)
      organization.valid?
      organization.errors.add(:markets, :blank)
    else
      market = user.markets.find(market_id)
      context[:organization] = market.organizations.create(organization_params)
    end

    fail! unless organization.errors.none?
  end
end
