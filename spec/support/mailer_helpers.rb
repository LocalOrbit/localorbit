module MailerHelpers
  def expect_send_fresh_sheet_mail(market:,to:,note:,unsubscribe_token:nil,port:80)
    expect(MarketMailer).to receive(:fresh_sheet).with(market: market, 
           to: to, 
           note: note,
           unsubscribe_token: unsubscribe_token,
           port:port).
           and_return(double(:mailer, deliver: true))
  end

  def expect_send_newsletter_mail(newsletter:,market:,to:,unsubscribe_token:nil,port:80)
    expect(MarketMailer).to receive(:newsletter).with(
           newsletter: newsletter, 
           market: market, 
           to: to, 
           unsubscribe_token: unsubscribe_token,
           port:port).
           and_return(double(:mailer, deliver: true))
  end
end

RSpec.configure do |config|
  config.include MailerHelpers
end
