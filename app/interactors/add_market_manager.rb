class AddMarketManager
  include Interactor

  def perform
    require_in_context(:market, :email, :inviter)

    user = User.find_for_authentication(email: email)

    if user
      market.managers << user
      UserMailer.delay(queue: 'urgent').market_invitation(user, inviter, market)
    else
      user = User.invite!({email: email, managed_markets: [market]}, inviter)
    end

    if !user.organizations.include?(market.organization)
      user.organizations << market.organization
    end
  end
end
