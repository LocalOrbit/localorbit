class ActivateOrganization
  include Interactor

  def perform
    # Temporarily Activate All Organizations until auto-activation is ready
    organization.update!(active: true)
    return

    return unless organization.markets.includes(market)
    return if organization.can_sell?

    if market.auto_activate_organizations?
      organization.update!(active: true)
    end
  end
end
