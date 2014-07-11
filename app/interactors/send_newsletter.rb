class SendNewsletter
  include Interactor

  def perform
    if commit == "Send Test"
      MarketMailer.delay.newsletter(newsletter, market, email)
      context[:notice] = "Successfully sent a test to #{email}"
    elsif commit == "Send Now"
      emails = newsletter.recipients.map {|name, email| "#{name.inspect} <#{email}>" }
      emails.each do |email|
        MarketMailer.delay.newsletter(newsletter, market, email)
      end
      context[:notice] = "Successfully sent this Newsletter"
    else
      context[:notice] = nil
    end
  end
end
