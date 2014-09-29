require "spec_helper"

describe SendNewsletter do
  include_context "the fresh market"

  let!(:news_for_all) { create(:newsletter, :everyone, market: fresh_market) }
  let!(:buyers_news) { create(:newsletter, :buyers, market: fresh_market) }
  let!(:sellers_news) { create(:newsletter, :sellers, market: fresh_market) }
  let!(:managers_news) { create(:newsletter, :market_managers, market: fresh_market) }

  it "sends test emails" do
    context = SendNewsletter.perform(
      market: fresh_market,
      commit: "Send Test",
      email: "hossnfeffer@example.com",
      newsletter: news_for_all,
      port: 80
    )

    expect(context.success?).to eq(true)
    expect(context.notice).to eq("Successfully sent a test to hossnfeffer@example.com")

    mail = ActionMailer::Base.deliveries.shift
    expect(mail).to be

    assert_newsletter_sent_to mail, fresh_market, "hossnfeffer@example.com", news_for_all
  end

  describe "sending to groups" do
    let!(:newsletter_type) { create(:subscription_type, 
                                    keyword: SubscriptionType::Keywords::Newsletter, 
                                    name: "Test News!") }
    before do 
      [mary, bill, basil, steve, sol, clarence, craig].each do |user|
        user.subscribe_to(newsletter_type)
      end
      # Barry's not subscribed
    end

    it "sends to Market Managers" do
      mails = send_newsletter(managers_news)
      assert_newsletter_sent_to mails.first, fresh_market, mary.email, managers_news
    end

    it "sends to Buyers" do
      mails = send_newsletter(buyers_news).group_by do |m| m.to.first end
      expect(mails.keys).to contain_exactly(bill.email, basil.email)
      assert_newsletter_sent_to mails[bill.email].first, fresh_market, bill.email, buyers_news
      assert_newsletter_sent_to mails[basil.email].first, fresh_market, basil.email, buyers_news
    end

    it "sends to Sellers" do
      mails = send_newsletter(sellers_news).group_by do |m| m.to.first end
      expect(mails.keys).to contain_exactly(steve.email, basil.email)
      assert_newsletter_sent_to mails[steve.email].first, fresh_market, steve.email, sellers_news
      assert_newsletter_sent_to mails[basil.email].first, fresh_market, basil.email, sellers_news
    end

    it "sends to all selected groups" do
      expected_emails = [mary, bill, basil, steve].map(&:email)

      mails = send_newsletter(news_for_all).group_by do |m| m.to.first end
      expect(mails.keys).to contain_exactly(*expected_emails)
      expected_emails.each do |email|
        assert_newsletter_sent_to mails[email].first, fresh_market, email, news_for_all
      end
    end
  end

  it "do nothing on unknown action" do
    context = SendNewsletter.perform(
      commit: "lol wat",
      market: fresh_market, 
      newsletter: news_for_all, 
      email:"hossnfeffer@example.com", port:80)

    expect(context.success?).to eq(true)
    expect(context.notice).to be_nil
  end

  #
  # HELPERS
  #
  def send_newsletter(newsletter)
    context = SendNewsletter.perform(newsletter: newsletter, 
                           market: fresh_market, 
                           commit: "Send Now",port:80)
  
    expect(context.success?).to eq(true)
    expect(context.notice).to eq("Successfully sent this Newsletter")
  
    return ActionMailer::Base.deliveries
  end
  
  def assert_newsletter_sent_to(mail,market,sent_to,newsletter)
    expect(mail).to be
    expect(mail.to.first).to eq(sent_to)
    expect(mail.subject).to eq(newsletter.subject)
  end
end
