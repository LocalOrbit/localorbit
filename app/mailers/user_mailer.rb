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

  def organization_off_waiting_list(organization, market)
    @market = market || organization.markets.last
    @organization = organization
    @recipients = @organization.users.map(&:email)

    mail(
      to: @recipients,
      subject: "You're off the #{@market.name} waiting list"
    )
  end

  def market_request_confirmation(market)
    @market = market

    mail(
      to: @market.pretty_email,
      subject: "Your new Market request has been received"
    )
  end

  def market_welcome(market)
    @market = market

    mail(
      to: @market.pretty_email,
      subject: "Your new Market request has been confirmed"
    )
  end
end
