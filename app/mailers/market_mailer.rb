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

  def pending_cross_selling_list(publisher, cross_selling_list)
    @publisher = @market = publisher
    @cross_selling_list = cross_selling_list
    @subscriber = cross_selling_list.entity

    # KXM TESTING ONLY
    # recipients = @target.managers.map(&:pretty_email)
    recipients = ["\"Keith Meisel\" <keith@localorb.it>"]

    if recipients.any?
      mail(
        to: recipients,
        subject: "#{@publisher.name} has shared a new Cross Selling List"
      )
    end
  end

  def revoked_cross_selling_list(publisher, cross_selling_list)
    @publisher = @market = publisher
    @cross_selling_list = cross_selling_list
    @subscriber = cross_selling_list.entity

    # KXM TESTING ONLY
    # recipients = @target.managers.map(&:pretty_email)
    recipients = ["\"Keith Meisel\" <keith@localorb.it>"]

    if recipients.any?
      mail(
        to: recipients,
        subject: "Cross Selling List '#{@cross_selling_list.name}' is no longer available"
      )
    end
  end

  def activated_cross_selling_list(subscriber, parent_list)
    @subscriber = @market = subscriber
    @parent_list = parent_list
    @publisher = parent_list.entity

    # KXM TESTING ONLY
    # recipients = @target.managers.map(&:pretty_email)
    recipients = ["\"Keith Meisel\" <keith@localorb.it>"]

    if recipients.any?
      mail(
        to: recipients,
        subject: "#{@subscriber.name} has activated your Cross Selling List"
      )
    end
  end

  def declined_cross_selling_list(subscriber, parent_list)
    @subscriber = @market = subscriber
    @parent_list = parent_list
    @publisher = parent_list.entity

    # KXM TESTING ONLY
    # recipients = @target.managers.map(&:pretty_email)
    recipients = ["\"Keith Meisel\" <keith@localorb.it>"]

    if recipients.any?
      mail(
        to: recipients,
        subject: "#{@subscriber.name} has declined your Cross Selling List"
      )
    end
  end

  def cross_selling_list(from_market, cross_selling_list)
    @market = from_market
    @cross_selling_list = cross_selling_list
    @target = cross_selling_list.entity

    recipients = @target.managers.map(&:pretty_email)

    if recipients.any?
      mail(
        to: recipients,
        subject: "Pending cross selling list"
      )
    end
  end
end
