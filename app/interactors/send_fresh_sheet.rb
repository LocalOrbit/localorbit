class SendFreshSheet
  include Interactor

  def perform
    if commit == "Send Test"
      send_test_email

    elsif commit == "Send to Everyone Now"
      send_fresh_sheets_to_subscribed_members

    else
      context[:error] = "Invalid action chosen"
      context.fail!
    end
  end

  private

  def send_test_email
    MarketMailer.delay.fresh_sheet(market: market, to: email, note: note.to_s.html_safe, unsubscribe_token: "XYZ987", port: get_port)
    context[:notice] = "Successfully sent a test to #{email}"
  end

  def send_fresh_sheets_to_subscribed_members
    fresh_sheet_type = SubscriptionType.find_by(keyword: SubscriptionType::Keywords::FreshSheet)
    User.in_market(market).
      subscribed_to(fresh_sheet_type).
      uniq. 
      includes(:subscriptions).
      each do |user|
        token = user.unsubscribe_token(subscription_type: fresh_sheet_type)
        MarketMailer.delay.fresh_sheet(market: market, 
                                       to: user.pretty_email, 
                                       note: note.to_s.html_safe,
                                       unsubscribe_token: token,
                                       port: get_port)
      end
    context[:notice] = "Successfully sent the Fresh Sheet"
  end

  def get_port
    if respond_to?(:port)
      port
    else
      80
    end
  end
end
