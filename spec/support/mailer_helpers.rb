module MailerHelpers
  def expect_send_fresh_sheet_mail(market:,to:,note:,unsubscribe_token:nil)
    expect(MarketMailer).to receive(:fresh_sheet).with(market: market, 
           to: to, 
           note: note,
           unsubscribe_token: unsubscribe_token).
           and_return(double(:mailer, deliver: true))
  end
end

RSpec.configure do |config|
  config.include MailerHelpers
end
