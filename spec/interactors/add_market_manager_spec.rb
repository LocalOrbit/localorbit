require "spec_helper"

describe AddMarketManager do
  let!(:inviter) { create(:user, :admin) }
  let!(:market) { create(:market) }

  describe "adding an existing user" do
    let!(:user) { create(:user, role: "user") }

    it "adds them to the market's managers list" do
      result = AddMarketManager.perform(market: market, email: user.email, inviter: inviter)

      expect(result).to be_success
      expect(market.managers(true)).to include(user)
    end

    it "lookup is case case insensitive" do
      result = AddMarketManager.perform(market: market, email: user.email.upcase, inviter: inviter)

      expect(result).to be_success
      expect(market.managers(true)).to include(user)
    end

    it "sends an email" do
      result = AddMarketManager.perform(market: market, email: user.email, inviter: inviter)

      expect(result).to be_success

      open_email(user.email)
      expect(current_email).to have_subject("You have been added to a market")
      expect(current_email).to have_body_text("You have been added as a Market Manager for #{market.name}")
      expect(current_email).to have_body_text("View #{market.name}")
    end
  end

  describe "adding a new user" do
    it "creates a new user" do
      expect do
        result = AddMarketManager.perform(market: market, email: "new-user@example.com", inviter: inviter)
        expect(result).to be_success
      end.to change {
        User.count
      }.from(1).to(2)
    end

    it "sends the new user an invitation email" do
      result = AddMarketManager.perform(market: market, email: "new-user@example.com", inviter: inviter)
      expect(result).to be_success

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq(["new-user@example.com"])
    end

    it "adds the new user to the market's managers list" do
      result = AddMarketManager.perform(market: market, email: "new-user@example.com", inviter: inviter)
      expect(result).to be_success

      new_user = User.where(email: "new-user@example.com").first
      expect(market.managers(true)).to include(new_user)
    end
  end
end
