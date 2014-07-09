class SendFreshSheet
  include Interactor

  def perform
    if commit == "Send Test"
      MarketMailer.delay.fresh_sheet(market.id, email, note)
      context[:notice] = "Successfully sent a test to #{email}"
    elsif commit == "Send to Everyone Now"
      emails.each do |email|
        MarketMailer.delay.fresh_sheet(market.id, email, note)
      end
      context[:notice] = "Successfully sent the Fresh Sheet"
    else
      context[:error] = "Invalid action chosen"
      context.fail!
    end
  end

  private

  def emails
    @emails ||= User.joins(organizations: :market_organizations).
      where(send_freshsheet: true, market_organizations: {market_id: market.id}).
      uniq.pluck(:name, :email). # putting uniq first has the database de-dup the data
      map {|name, email| name.blank? ? email : "#{name.inspect} <#{email}>" }
  end
end
