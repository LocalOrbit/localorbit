require 'spec_helper'

describe AddMarketManager do
  let!(:market) { FactoryGirl.create(:market) }

  describe 'adding an existing user' do
    let!(:user) { FactoryGirl.create(:user, role: 'user') }

    it "adds them to the market's managers list" do
      result = AddMarketManager.perform(market: market, email: user.email)

      expect(result).to be_success
      expect(market.managers(true)).to include(user)
    end
  end

  describe 'adding a new user' do
    it 'creates a new user' do
      expect {
        result = AddMarketManager.perform(market: market, email: 'new-user@example.com')
        expect(result).to be_success
      }.to change {
        User.count
      }.from(0).to(1)
    end

    it 'sends the new user an invitation email' do
      result = AddMarketManager.perform(market: market, email: 'new-user@example.com')
      expect(result).to be_success

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq(['new-user@example.com'])
    end

    it "adds the new user to the market's managers list" do
      result = AddMarketManager.perform(market: market, email: 'new-user@example.com')
      expect(result).to be_success

      new_user = User.where(email: 'new-user@example.com').first
      expect(market.managers(true)).to include(new_user)
    end
  end
end
