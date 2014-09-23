class SendNewsletter
  include Interactor

  def perform
    if commit == "Send Test"
      MarketMailer.delay.newsletter(newsletter.id, market.id, email)
      context[:notice] = "Successfully sent a test to #{email}"
    elsif commit == "Send Now"
      emails = newsletter.recipients.map(&:pretty_email) # XXX
      #TODO emails = newsletter.recipients.select(:name,:email).map(&:pretty_email)
      emails.each do |email|
        MarketMailer.delay.newsletter(newsletter.id, market.id, email)
      end
      context[:notice] = "Successfully sent this Newsletter"
    else
      context[:notice] = nil
    end
  end
end
