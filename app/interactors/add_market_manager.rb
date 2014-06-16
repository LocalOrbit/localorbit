class AddMarketManager
  include Interactor

  def perform
    user = User.find_for_authentication(email: email)

    if user
      market.managers << user
      UserMailer.market_invitation(user, inviter, market).deliver
    else
      user = User.invite!({email: email, managed_markets: [market]}, inviter)
    end
  end
end
