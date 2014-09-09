require "spec_helper"

describe PayMarketForOrders do
  let!(:market)            { create(:market) }
  let!(:market_manager)    { create(:user, managed_markets: [market]) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery)          { delivery_schedule.next_delivery }
  let!(:bank_account)      { create(:bank_account, :checking, :verified, bankable: market, balanced_uri: "/bank-account-1") }
  let!(:orders)            { [create(:order, market: market, delivery: delivery), create(:order, market: market, delivery: delivery), create(:order, market: market, delivery: delivery)] }
  let(:order_ids)          { orders.map(&:id) }
  let(:balanaced_bank_account) { double(Balanced::BankAccount, credit: balanced_credit) }
  let(:balanced_credit)    { double(Balanced::Credit, uri: "/balanced-credit-1") }

  before do
    expect(Balanced::BankAccount).to receive(:find).with("/bank-account-1").and_return(balanaced_bank_account)

    expect(Market).to receive(:find).with(market.id).and_return(market)
    expect(market).to receive(:orders).and_return(double("orders", find: orders))

    expect(orders[0]).to receive(:payable_to_market).and_return(32.50)
    expect(orders[1]).to receive(:payable_to_market).and_return(321.32)
    expect(orders[2]).to receive(:payable_to_market).and_return(251.42)
  end

  let(:interactor) { PayMarketForOrders.perform(market_id: market.id, bank_account_id: bank_account.id, order_ids: order_ids) }

  it "records a payment with the correct details" do
    expect {
      interactor
    }.to change {
      Payment.count
    }.from(0).to(1)

    p = Payment.first
    expect(p.orders).to contain_exactly(*orders)
    expect(p.market).to eq(market)
    expect(p.bank_account).to eq(bank_account)
    expect(p.payee).to eq(market)
    expect(p.payment_type).to eq("market payment")
    expect(p.amount).to eq(605.24)
    expect(p.status).to eq("pending")
    expect(p.payment_method).to eq("ach")
    expect(p.balanced_uri).to eq("/balanced-credit-1")
  end

  it "generates the appropriate balanced transaction" do
    expect(balanaced_bank_account).to receive(:credit).with(amount: 60_524, description: "Local Orbit", appears_on_statement_as: "Local Orbit").and_return(balanced_credit)

    interactor
  end

  it "records the payment as failed if balanced encounters an error" do
    expect(balanaced_bank_account).to receive(:credit).and_raise(StandardError)

    expect {
      expect(interactor).not_to be_success
    }.to change {
      Payment.count
    }.from(0).to(1)

    expect(Payment.first.status).to eq("failed")
  end

  it "sends an email to the market manager" do
    interactor

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    open_last_email
    expect(current_email).to be_delivered_to(market_manager.email)
  end
end
