require 'spec_helper'

describe SendFreshSheet do

  let!(:market) { create(:market, name: 'Mad Dog Farm n Fry', delivery_schedules: [create(:delivery_schedule)]) }
  let(:note) { 'B flat' } #lol
  let(:fresh_subscription) do
    create(:subscription_type,
           keyword: SubscriptionType::Keywords::FreshSheet,
           name: 'Test Fresh!')
  end

  let!(:subscribed_buyer) do
    user = create(:user, :buyer)
    create(:organization, :buyer, users:[user], markets:[market])
    user.subscribe_to(fresh_subscription)
    user
  end

  let!(:subscribed_supplier) do
    user = create(:user, :supplier)
    create(:organization, :seller, users:[user], markets:[market])
    user.subscribe_to(fresh_subscription)
    user
  end

  #Note - this context currently tests a private method on the interactor that
  #should eventually be separated into its own object
  context 'finding valid subscribers' do

    let(:target_users) do
      interactor = SendFreshSheet.new
      interactor.context[:market] = market
      interactor.send(:fresh_sheet_subscribers)
    end

    context 'when market users have been deactivated from an organization' do
      before :each do
        UserOrganization.where(user_id: subscribed_buyer.id).update_all(enabled: false)
      end
      it 'should not find deactivated organization users' do
        expect(target_users).not_to include(subscribed_buyer)
      end
    end

    context "when a user's only organization in the market is disabled" do
      before :each do
        subbed_org_ids = subscribed_buyer.organizations.pluck :id
        Organization.where(id: subbed_org_ids).update_all(active: false)
      end
      it 'should not find the user' do
        expect(target_users).not_to include(subscribed_buyer)
      end
    end

    context "when a user has active and inactive organizations in the market" do
      before :each do
        inactive_org = create(:organization,
                              :buyer,
                              users:[subscribed_buyer],
                              markets:[market],
                              active: false
                             )
        subscribed_buyer.organizations << inactive_org
      end
      it 'should find the user' do
        expect(target_users).to include(subscribed_supplier)
      end
    end

    context 'when users exist in other markets' do
      let!(:subscriber_in_other_market) do
        user = create(:user, :buyer)
        create(:organization, :buyer, users:[user], markets:[create(:market)])
        user.subscribe_to(fresh_subscription)
        user
      end
      it 'should not find users only belonging to other markets' do
        expect(target_users).not_to include(subscriber_in_other_market.email)
      end
    end

    context 'when there are unsubscribed users in the market' do
      let!(:unsubscribed_buyer) do
        user = create(:user, :buyer)
        create(:organization, :buyer, users:[user], markets:[market])
        user.subscribe_to(fresh_subscription)
        user.unsubscribe_from(fresh_subscription)
        user
      end
      it 'should not find unsubscribed users' do
        expect(target_users).not_to include(unsubscribed_buyer)
      end
    end

    context 'when there unconfirmed users for the market' do
      before :each do
        subscribed_buyer.update_column(:confirmed_at, nil)
      end
      it 'should not find unconfirmed users' do
        expect(target_users).not_to include(subscribed_buyer)
      end
    end
  end

  describe '.perform' do
    let(:commit) {'Send to Everyone Now'}

    let! (:context) do
      SendFreshSheet.perform(
        market: market,
        commit: commit,
        note: note)
    end

    it 'should set success in the interactor context' do
      expect(context.success?).to eq(true)
      expect(context.notice).to eq('Successfully sent the Fresh Sheet')
    end

    it 'should have valid data in the emails' do
      mails = ActionMailer::Base.deliveries
      mail1 = mails.select do |m| m.to.first == subscribed_buyer.email end.first
      assert_fresh_sheet_sent_to mail1, market, subscribed_buyer.email, note

      mail2 = mails.select do |m| m.to.first == subscribed_supplier.email end.first
      assert_fresh_sheet_sent_to mail2, market, subscribed_supplier.email, note
    end

    context 'with bad commit value' do
      let(:commit){'oops bad'}
      it 'fails' do
        expect(context.failure?).to eq(true)
        expect(context.error).to eq('Invalid action chosen')
      end
    end
  end

  it 'sends test emails' do
    context = SendFreshSheet.perform(
      market: market,
      commit: 'Send Test',
      email: 'hossnfeffer@example.com',
      note: note)
    expect(context.success?).to eq(true)
    expect(context.notice).to eq('Successfully sent a test to hossnfeffer@example.com')

    mail = ActionMailer::Base.deliveries.shift
    expect(mail).to be

    assert_fresh_sheet_sent_to mail, market, 'hossnfeffer@example.com', note
  end

  # HELPERS
  def assert_fresh_sheet_sent_to(mail,market,sent_to,note)
    expect(mail).to be
    expect(mail.to.first).to eq(sent_to)
    expect(mail.subject).to match(/fresh/i)
    expect(mail.body).to match(/#{market.name}/)
    expect(mail.body).to match(/#{note}/)
  end
end
