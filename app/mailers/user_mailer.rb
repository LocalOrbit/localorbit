class UserMailer < ActionMailer::Base
  layout "email"
  default from: "service@localorb.it"

  def organization_invitation(user, organization, inviter, market)
    @user = user
    @organization = organization
    @inviter = inviter
    @market = market

    mail(
      to: @user.email,
      subject: "You have been added to an organization"
    )
  end

  def market_invitation(user, inviter, market)
    @user = user
    @inviter = inviter
    @market = market

    mail(
      to: @user.email,
      subject: "You have been added to a market"
    )
  end
end
