require 'spec_helper'

describe LocalOrbit::DeviseMailer do
  let(:market)   { create(:market, organizations: [organization], contact_email: 'manager@market.com') }
  let!(:manager) { create(:user, :market_manager, managed_markets: [market]) }
  let(:organization) { create(:organization, :seller, :single_location, active: false) }
  let!(:user)        { create(:user, :supplier, organizations: [organization]) }

  describe 'invitation_instructions' do
    let(:mailer)   { LocalOrbit::DeviseMailer.invitation_instructions(user, 'abc123') }

    it 'has reply-to set to market manager' do
      expect(mailer.reply_to).to contain_exactly('manager@market.com')
    end
  end

  describe 'confirmation_instructions' do
    let(:mailer)   { LocalOrbit::DeviseMailer.confirmation_instructions(user, 'abc123') }

    it 'has reply-to set to market manager' do
      expect(mailer.reply_to).to contain_exactly('manager@market.com')
    end
  end

  describe 'reset_import_password_instructions' do
    let(:mailer)   { LocalOrbit::DeviseMailer.reset_import_password_instructions(user, 'abc123') }

    it 'has reply-to set to market manager' do
      expect(mailer.reply_to).to contain_exactly('manager@market.com')
    end
  end
end