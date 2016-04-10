class MarketMailer < BaseMailer

  def fresh_sheet(market:, to: nil, note: nil, preview: false, unsubscribe_token: nil, port: nil)
    @preview        = preview
    @note           = note
    @market         = market
    @delivery       = @market.next_delivery.decorate if !@market.next_delivery.nil?

    default_url_options[:host] = @market.domain if @market and @market.domain
    default_url_options[:port] = port if port
    if unsubscribe_token
      @unsubscribe_url = unsubscribe_subscriptions_url(token: unsubscribe_token)
    end

    organization    = @market.organizations.build
    cart            = Cart.new(market: @market, organization: organization)
    @products_for_sale = ProductsForSale.new(@delivery, organization, cart)

    mail(
      to: to,
      subject: "See what's fresh this week!"
    )
  end

  # def newsletter(newsletter_id, market_id, recipients=nil)
  def newsletter(newsletter:, market:, to: nil, unsubscribe_token: nil, port: nil)
    @newsletter = newsletter
    @market     = market

    default_url_options[:host] = @market.domain if @market and @market.domain
    default_url_options[:port] = port if port
    if unsubscribe_token
      @unsubscribe_url = unsubscribe_subscriptions_url(token: unsubscribe_token)
    end

    mail(
      to: to,
      subject: @newsletter.subject
    )
  end

  def registration(market, organization)
    @market = market
    @organization = organization
    recipients = market.managers.map(&:pretty_email)

    if recipients.any?
      mail(
        to: recipients,
        subject: "New organization registration"
      )
    end
  end
end
