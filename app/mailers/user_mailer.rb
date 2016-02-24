class UserMailer < BaseMailer
  def organization_invitation(user, organization, inviter, market)
    @user = user
    @organization = organization
    @inviter = inviter
    @market = market

    mail(
      to: @user.pretty_email,
      subject: "You have been added to an organization"
    )
  end

  def market_invitation(user, inviter, market)
    @user = user
    @inviter = inviter
    @market = market

    mail(
      to: @user.pretty_email,
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

  def organization_activated(organization, market)
    @market = market || organization.markets.last
    @organization = organization
    @recipients = @organization.users.map(&:email)

    mail(
      to: @recipients,
      subject: "Welcome to #{@market.name}"
    )
  end

  def market_request_confirmation(user, market, invoice)
    @user = user
    @market = market
    @invoice = invoice

    # This forces the email template to display the Local Orbit number regardless of the existence of a Market
    @supress = true

    mail(
      to: @user.pretty_email,
      subject: "Your new Market request has been received"
    )
  end

  def market_welcome(user, market)
    @user = user
    @market = market

    # This forces the email template to display the Local Orbit number regardless of the existence of a Market
    @supress = true

    mail(
      to: @user.pretty_email,
      subject: "Your new Market request has been confirmed"
    )
  end
end
