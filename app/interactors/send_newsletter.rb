class SendNewsletter
  include Interactor

  def perform
    if commit == "Send Test"
      MarketMailer.newsletter(newsletter, market, email).deliver
      context[:notice] = "Successfully sent a test to #{email}"
    elsif commit == "Send Now"
      emails = newsletter.recipients.map {|name, email| "#{name} <#{email}>" }
      MarketMailer.newsletter(newsletter, market, emails).deliver if emails.present?
      context[:notice] = "Successfully sent this Newsletter"
    else
      context[:notice] = nil
    end
  end
end
