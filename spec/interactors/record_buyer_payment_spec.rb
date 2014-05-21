require "spec_helper"

describe RecordBuyerPayment do
  let(:market) { create(:market, po_payment_term: 14) }

  let!(:buyer_user) { create :user }

  let!(:seller) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:buyer)  { create(:organization, :buyer,  name: "Money Bags",   markets: [market], users: [buyer_user]) }

  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:order1) { create(:order, items: [create(:order_item, product: product)], market: market, organization: buyer, payment_method: "purchase order", order_number: "LO-001", total_cost: 210, placed_at: 19.days.ago, invoiced_at: 18.days.ago, invoice_due_date: 4.days.ago) }

  let(:run_payment) { RecordBuyerPayment.perform(order: order1, payment_params: {payment_method: "check", amount: "210", note: "Check #6341"}) }

  it "saves a payment record with the correct attributes" do
    expect {
      run_payment
    }.to change {
      Payment.count
    }.from(0).to(1)

    p = Payment.first
    expect(p.payment_method).to eq("check")
    expect(p.amount).to eq(210)
    expect(p.note).to eq("Check #6341")
  end

  it "payment should be associated with the order" do
    run_payment
    expect(Payment.first.orders).to eq([order1])
  end

  it "marks the order paid" do
    run_payment
    expect(order1.reload.payment_status).to eq("paid")
  end
end
