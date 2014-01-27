class AddMarketManager
  include Interactor

  def perform
    user = User.where(email: email).first
    user ||= User.invite!({:email => email}, inviter)
    market.managers << user
  end
end
