require "spec_helper"

describe SendFreshSheet do
  
  let!(:market) { create(:market, name: "Mad Dog Farm n Fry", delivery_schedules: [create(:delivery_schedule)]) }
  let(:note) { "B flat" }

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

  it "sends Fresh Sheet emails to all users in the given market who subscribe to Fresh Sheets" do
    fresh = create(:subscription_type, 
                   keyword: SubscriptionType::Keywords::FreshSheet, 
                   name: "Test Fresh!")

    user1 = create(:user, :buyer)
    user2 = create(:user, :supplier)
    user3 = create(:user, :buyer)
    user4 = create(:user, :buyer)
    [user1,user2,user3,user4].each do |u|
      u.subscribe_to(fresh)
    end
    user3.unsubscribe_from(fresh)

    create(:organization, :buyer, users:[user1], markets:[market])
    create(:organization, :seller, users:[user2], markets:[market])
    create(:organization, :buyer, users:[user3], markets:[market])
    create(:organization, :buyer, users:[user4], markets:[create(:market)])

    # At this point, user1 and user2 are in our target Market and are subscribed.
    # user3 is in the Market but not subscribed.
    # user4 is subscribed, but in a different market

    context = SendFreshSheet.perform(market: market, commit: "Send to Everyone Now", note: note)
    expect(context.success?).to eq(true)
    expect(context.notice).to eq("Successfully sent the Fresh Sheet")

    mails = ActionMailer::Base.deliveries
    emails = mails.map(&:to).map do |recips| recips.first end
    expect(emails).to contain_exactly(user1.email, user2.email)

    mail1 = mails.select do |m| m.to.first == user1.email end.first
    assert_fresh_sheet_sent_to mail1, market, user1.email, note

    mail2 = mails.select do |m| m.to.first == user2.email end.first
    assert_fresh_sheet_sent_to mail2, market, user2.email, note
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
