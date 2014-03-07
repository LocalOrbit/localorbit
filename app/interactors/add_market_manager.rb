class AddMarketManager
  include Interactor

  def perform
    user = User.find_for_authentication(email: email)
    user ||= User.invite!({email: email}, inviter)
    market.managers << user
  end
end
