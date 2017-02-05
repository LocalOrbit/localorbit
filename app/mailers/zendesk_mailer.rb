class ZendeskMailer < ActionMailer::Base
  default to: Figaro.env.zendesk_email

  def request_unit(user, new_unit_params)
    @user = user
    @unit_params = new_unit_params

    mail(
      from: Figaro.env.zendesk_email,
      subject: "A new unit has been requested"
    )
  end

  def request_category(user, category)
    @user = user
    @category = category

    mail(
      from: Figaro.env.zendesk_email,
      subject: "A new category has been requested"
    )
  end

  def request_market(market)
    @market = market

    mail(
      to: "service@localorbit.com",
      from: @market.pretty_email,
      subject: "A new Market has been requested"
    )
  end

  def failed_market_request(market, message)
    @market = market
    @message = message

    mail(
      to: "service@localorbit.com",
      from: @market.pretty_email,
      subject: "An attempt to create a new Market has failed"
    )
  end

  def error_intervention(user, title, data)
    @user = user
    @title = title
    @data = data

    mail(
      from: Figaro.env.zendesk_email,
      subject: "Requires admin review: #{title}"
    )
  end
end
