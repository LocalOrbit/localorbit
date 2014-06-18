class MarketMailer < BaseMailer

  def fresh_sheet(market, recipients=nil, preview=false)
    @preview        = preview
    @market         = market
    @delivery       = market.next_delivery.decorate
    organization    = market.organizations.build
    cart            = Cart.new(market: @market, organization: organization)

    @products_for_sale = ProductsForSale.new(@delivery, organization, cart)

    mail(
      to: recipients,
      subject: "See what's fresh this week!"
    )
  end

  def newsletter(newsletter, market, recipients=nil)
    @newsletter     = newsletter
    @market         = market

    mail(
      to: recipients,
      subject: @newsletter.subject
    )
  end

  def registration(market, organization)
    @market = market
    @organization = organization
    recipients = market.managers.map(&:email)

    if recipients.any?
      mail(
        to: recipients,
        subject: "New organization registration"
      )
    end
  end
end
