require 'spec_helper'

describe "stripe market transfer.paid event", vcr: true, webhook: true do
  let(:stripe_account_id) { "acct_15xJY9HouQbaP1MV" } # matches transfer.paid.json
  let(:stripe_transfer_id) { "tr_15xxwkHouQbaP1MV8O0tEg2b" } # matches transfer.paid.json
  let!(:market) { create(:market, stripe_account_id: stripe_account_id) }
  let!(:orders) { create_list(:order, 3, market: market) }

  # We need to brow-beat the test orders in the db to have IDs that match the hand-configured metadatain transfer.paid.json:
  let(:replace_order_ids) { [ 1234, 187, 1337 ] } 

  before do
    orders.zip(replace_order_ids).each do |order, new_id|
      forcibly_change_order_id(order, new_id)
    end
  end

  it "creates a payment and emails the market's managers" do
    expect(find_payments.count).to eq 0
    post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/transfer.paid.json'))


    expect(find_payments.count).to eq 1
    payment = find_payments.first
    expect(payment.payment_type).to eq "market payment"
    expect(payment.market).to eq market
    expect(payment.payee).to eq market
    expect(payment.amount).to eq "332.1".to_d
    expect(payment.stripe_transfer_id).to eq stripe_transfer_id

    fixed_orders = replace_order_ids.map do |id| Order.find(id) end
    expect(payment.orders.to_set).to eq fixed_orders.to_set

    # TODO: verify `current_email` sent to markets
    # raise "FINISH HIM"
  end

  #
  # HELPERS
  #

  def find_payments
    Payment.where(payee: market)
  end

  def forcibly_change_order_id(order, new_id)
    Order.where(id:order.id).update_all(id: new_id) # not something you'd normally do
  end

end
