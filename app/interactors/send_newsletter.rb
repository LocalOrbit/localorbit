class SendNewsletter
  include Interactor

  def perform
    newsletter.body = CGI::unescapeHTML(newsletter.body)

    if commit == "Send Test"
      MarketMailer.delay.newsletter(newsletter: newsletter, market: market, to: email, port: get_port, unsubscribe_token: "XYZ-test-unsub-newsletter-0986")
      context[:notice] = "Successfully sent a test to #{email}"

    elsif commit == "Send Now"
      newsletter_type = SubscriptionType.find_by(keyword: SubscriptionType::Keywords::Newsletter)
      newsletter.recipients.each do |user|
          token = user.unsubscribe_token(subscription_type: newsletter_type)
          MarketMailer.delay.newsletter(
            newsletter: newsletter, 
            market: market, 
            to: user.pretty_email, 
            unsubscribe_token: token,
            port: get_port)
        end
      context[:notice] = "Successfully sent this Newsletter"

    else
      context[:notice] = nil
    end
  end

  def get_port
    if respond_to?(:port)
      port
    else
      80
    end
  end
end
