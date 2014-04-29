class SendFreshSheet
  include Interactor

  def perform
    if commit == "Send Test"
      MarketMailer.fresh_sheet(market, email).deliver
      context[:notice] = "Successfully sent a test to #{email}"
    elsif commit == "Send to Everyone Now"
      emails = market.organizations.buying.joins(:users).
        where("users.send_freshsheet = ?", true).pluck(:name, :email).
        map {|name, email| "#{name} <#{email}>" }

      MarketMailer.fresh_sheet(market, emails).deliver if emails.present?
      context[:notice] = "Successfully sent the Fresh Sheet"
    else
      context[:error] = "Invalid action chosen"
      context.fail!
    end
  end
end
