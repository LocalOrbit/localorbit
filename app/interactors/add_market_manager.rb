class AddMarketManager
  include Interactor

  def perform
    user = User.find_for_authentication(email: email)

    if user
      UserMailer.market_invitation(user, inviter, market).deliver
    else
      user = User.invite!({email: email}, inviter)
    end

    market.managers << user
  end
end
