require 'spec_helper'

RSpec.describe 'Stripe transfer events', :vcr, type: :request do
  before(:each) { bypass_event_signature payload }

  describe 'transfer.paid event' do                                                                             end
    let(:stripe_account_id) { 'acct_15xJY9HouQbaP1MV' } # matches transfer.paid.json
    let(:stripe_transfer_id) { 'tr_15xxwkHouQbaP1MV8O0tEg2b' } # matches transfer.paid.json
    let!(:market) { create(:market, stripe_account_id: stripe_account_id) }
    let!(:merri) { create(:user, :market_manager, name: 'Merri', managed_markets: [market]) }
    let!(:orders) { create_list(:order, 3, market: market) }

    # We need to brow-beat the test orders in the db to have IDs that match the hand-configured metadatain transfer.paid.json:
    let(:replace_order_ids) { [ 1234, 187, 1337 ] }
    let(:payload) { File.read('spec/features/webhooks/transfer.paid.json') }

    before do
      orders.zip(replace_order_ids).each do |order, new_id|
        forcibly_change_order_id(order, new_id)
      end
    end

    # FIXME see LO-1074: when legacy cassette is deleted this fails, event has changed to transfer.created,
    #   and lo.order_id metadata is missing
    # NOTE: we are not currently subscribed to this event on production!
    it "creates a payment and emails the market's managers" do
      expect(find_payments.count).to eq 0
      post '/webhooks/stripe', payload

      expect(response).to have_http_status(:ok)

      # See the Payment in the database:
      expect(find_payments.count).to eq 1
      payment = find_payments.first
      expect(payment.payment_type).to eq "market payment"
      expect(payment.market).to eq market
      expect(payment.payee).to eq market
      expect(payment.amount).to eq '332.1'.to_d
      expect(payment.stripe_transfer_id).to eq stripe_transfer_id

      fixed_orders = replace_order_ids.map do |id| Order.find(id) end
      expect(payment.orders.to_set).to eq fixed_orders.to_set

      # Verify email was sent:
      mail = ActionMailer::Base.deliveries[0] # Market payment is probably first.
      expect(mail).to be, 'No payment email sent'
      expect(mail.to).to eq market.managers.map(&:email)
      expect(mail.subject).to eq 'You Have Received a Payment'
      expect(mail.body).to match(/You have received a payment/i)
      expect(mail.body).to match(/payment was sent to.*#{market.name}/i)
      expect(mail.body).to match(/Visit #{market.name}/)
      expect(mail.body).to match(/#{Regexp.escape("$332.10")}/)
    end

    def find_payments
      Payment.where(payee: market)
    end

    def forcibly_change_order_id(order, new_id)
      Order.where(id:order.id).update_all(id: new_id) # not something you'd normally do
    end
  end
end
