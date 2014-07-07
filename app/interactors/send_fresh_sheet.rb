class SendFreshSheet
  include Interactor

  def perform
    if commit == "Send Test"
      MarketMailer.delay.fresh_sheet(market, email)
      context[:notice] = "Successfully sent a test to #{email}"
    elsif commit == "Send to Everyone Now"
      emails.each do |email|
        MarketMailer.delay.fresh_sheet(market, email)
      end
      context[:notice] = "Successfully sent the Fresh Sheet"
    else
      context[:error] = "Invalid action chosen"
      context.fail!
    end
  end

  private

  def emails
    @emails ||= User.joins(:organizations).where(
      organizations: {id: market.organizations.buying.pluck(:id)},
      users: {send_freshsheet: true}
    ).
    pluck(:name, :email).
    map {|name, email| "#{name} <#{email}>" }.uniq
  end
end
