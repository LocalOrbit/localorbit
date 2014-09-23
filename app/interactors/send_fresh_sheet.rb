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
    MarketMailer.delay.fresh_sheet(market.id, email, note)
    context[:notice] = "Successfully sent a test to #{email}"
  end

  def send_fresh_sheets_to_subscribed_members
    User.in_market(market).
      subscribed_to(SubscriptionType::Keywords::FreshSheet).
      select(:name, :email).
      uniq. 
      map(&:pretty_email).
      each do |email|
        MarketMailer.delay.fresh_sheet(market.id, email, note)
      end
    context[:notice] = "Successfully sent the Fresh Sheet"
  end
end
