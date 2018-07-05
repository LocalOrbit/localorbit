require "spec_helper"

describe SendFreshSheet do

  let!(:market) { create(:market, name: "Mad Dog Farm n Fry", delivery_schedules: [create(:delivery_schedule)]) }
  let(:note) { "B flat" } #lol

  it "sends test emails" do
    context = SendFreshSheet.perform(
      market: market,
      commit: "Send Test",
      email: "hossnfeffer@example.com",
      note: note)
    expect(context.success?).to eq(true)
    expect(context.notice).to eq("Successfully sent a test to hossnfeffer@example.com")

    mail = ActionMailer::Base.deliveries.shift
    expect(mail).to be

    assert_fresh_sheet_sent_to mail, market, "hossnfeffer@example.com", note
  end

  context "sending to subscribers" do
    let(:fresh_subscription) { create(:subscription_type, keyword: SubscriptionType::Keywords::FreshSheet, name: "Test Fresh!") }

    let(:subscribed_buyer) do
      user = create(:user, :buyer)
      create(:organization, :buyer, users:[user], markets:[market])
      user.subscribe_to(fresh_subscription)
      user
    end

    let(:subscribed_supplier) do
      user = create(:user, :supplier)
      create(:organization, :seller, users:[user], markets:[market])
      user.subscribe_to(fresh_subscription)
      user
    end

    let(:unsubscribed_buyer) do
      user = create(:user, :buyer)
      create(:organization, :buyer, users:[user], markets:[market])
      user.subscribe_to(fresh_subscription)
      user.unsubscribe_from(fresh_subscription)
      user
    end

    let(:subscriber_in_other_market) do
      user = create(:user, :buyer)
      create(:organization, :buyer, users:[user], markets:[create(:market)])
      user.subscribe_to(fresh_subscription)
      user
    end

    context "sends Fresh Sheet emails to all users in the given market who subscribe to Fresh Sheets" do
      before :each do
        subscribed_buyer
        subscribed_supplier
      end

      it "should set success in the context" do
        context = SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
        expect(context.success?).to eq(true)
        expect(context.notice).to eq("Successfully sent the Fresh Sheet")
      end

      it "should not send to inactive markets" do
        market.update_column(:active, false)
        SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
        expect(ActionMailer::Base.deliveries.size).to equal(0)
      end

      it "should not send to markets users deactivated from organization" do
        UserOrganization.where(user_id: subscribed_buyer.id).update_all(enabled: false)

        SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
        mails = ActionMailer::Base.deliveries
        emails = mails.map(&:to).map do |recips| recips.first end
        expect(emails).not_to include(subscribed_buyer.email)
      end

      it "should not send to subscribed users from another market" do
        subscriber_in_other_market

        SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
        mails = ActionMailer::Base.deliveries
        emails = mails.map(&:to).map do |recips| recips.first end
        expect(emails).to_not contain_exactly(subscriber_in_other_market.email)
      end

      it "should not send to unsubscribed users" do
        unsubscribed_buyer

        SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
        mails = ActionMailer::Base.deliveries
        emails = mails.map(&:to).map do |recips| recips.first end
        expect(emails).to_not contain_exactly(unsubscribed_buyer.email)
      end

      it "should have valid data in the emails" do
        SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
        mails = ActionMailer::Base.deliveries
        mail1 = mails.select do |m| m.to.first == subscribed_buyer.email end.first
        assert_fresh_sheet_sent_to mail1, market, subscribed_buyer.email, note

        mail2 = mails.select do |m| m.to.first == subscribed_supplier.email end.first
        assert_fresh_sheet_sent_to mail2, market, subscribed_supplier.email, note
      end
    end
  end

  it "fails on bad commit value" do
    context = SendFreshSheet.perform(market: market, commit: "oops bad", email:"hossnfeffer@example.com", note:note)
    expect(context.failure?).to eq(true)
    expect(context.error).to eq("Invalid action chosen")
  end

  #
  # HELPERS
  #

  def assert_fresh_sheet_sent_to(mail,market,sent_to,note)
    expect(mail).to be
    expect(mail.to.first).to eq(sent_to)
    expect(mail.subject).to match(/fresh/i)
    expect(mail.body).to match(/#{market.name}/)
    expect(mail.body).to match(/#{note}/)
  end
end
