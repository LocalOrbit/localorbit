class MarketMailer < BaseMailer

  def fresh_sheet(market:, to: nil, note: nil, preview: false, unsubscribe_token: nil)
    @preview        = preview
    @note           = note
    @market         = market
    @delivery       = @market.next_delivery.decorate
    @unsubscribe_token = unsubscribe_token

    organization    = @market.organizations.build
    cart            = Cart.new(market: @market, organization: organization)

    @products_for_sale = ProductsForSale.new(@delivery, organization, cart)

    mail(
      to: to,
      subject: "See what's fresh this week!"
    )
  end

  def newsletter(newsletter_id, market_id, recipients=nil)
    @newsletter = Newsletter.find(newsletter_id)
    @market     = Market.find(market_id)

    mail(
      to: recipients,
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
