class UserMailer < BaseMailer
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

  def user_updated(user, updater, original_email)
    @user = user
    @updater = updater

    recipients = [@user.email, original_email].uniq

    mail(
      to: recipients,
      subject: "Your account has been updated"
    )
  end
end
