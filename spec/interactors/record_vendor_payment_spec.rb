require "spec_helper"

describe RecordVendorPayment do
  let(:market) { create(:market, po_payment_term: 14) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market, day: 3.days.ago.wday) }
  let!(:delivery) { Timecop.freeze(5.days.ago) { delivery_schedule.next_delivery } }

  let!(:seller1) { create(:organization, :seller, name: "Better Farms", markets: [market]) }
  let!(:seller2) { create(:organization, :seller, name: "Great Farms",  markets: [market]) }
  let!(:buyer)   { create(:organization, :buyer,  name: "Money Bags",   markets: [market]) }

  let!(:product1) { create(:product, :sellable, organization: seller2) }
  let!(:product2) { create(:product, :sellable, organization: seller2) }
  let!(:product3) { create(:product, :sellable, organization: seller1) }

  let!(:order2) { create(:order, items: [create(:order_item, :delivered, product: product1, quantity: 3), create(:order_item, :delivered, product: product3, quantity: 7)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-001", total_cost: 69.90, placed_at: 6.days.ago, payment_status: "paid") }
  let!(:order3) { create(:order, items: [create(:order_item, :delivered, product: product2, quantity: 6)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-002", total_cost: 41.94, placed_at: 4.days.ago) }
  let!(:order4) { create(:order, items: [create(:order_item, :delivered, product: product1, quantity: 9), create(:order_item, :delivered, product: product2, quantity: 14)], market: market, organization: buyer, delivery: delivery, payment_method: "purchase order", order_number: "LO-003", total_cost: 160.77, placed_at: 3.days.ago) }

  it "adds the appropriate orders to the payment" do
    RecordVendorPayment.perform(seller: seller2, payment_params: {payment_method: "check", note: "43251", order_ids: [order2.id, order3.id]})

    payment = Payment.first
    expect(payment.orders.size).to eq(2)
    expect(payment.orders).to include(order2, order3)
  end

  it "records the correct payment amount for the given orders" do
    RecordVendorPayment.perform(seller: seller2, payment_params: {payment_method: "check", note: "43251", order_ids: [order2.id, order3.id]})

    payment = Payment.first
    expect(payment.amount).to eq(62.91)
  end

  it "records the correct payment type and note" do
    RecordVendorPayment.perform(seller: seller2, payment_params: {payment_method: "check", note: "43251", order_ids: [order2.id, order3.id]})

    payment = Payment.first
    expect(payment.payment_method).to eq("check")
    expect(payment.note).to eq("43251")
  end

  it "records the payment status as paid for checks" do
    RecordVendorPayment.perform(seller: seller2, payment_params: {payment_method: "check", note: "43251", order_ids: [order2.id, order3.id]})

    payment = Payment.first
    expect(payment.status).to eq("paid")
  end

  it "records the payment status as paid for cash" do
    RecordVendorPayment.perform(seller: seller2, payment_params: {payment_method: "cash", order_ids: [order2.id, order3.id]})

    payment = Payment.first
    expect(payment.status).to eq("paid")
  end

  it "records the payment type as seller payment" do
    RecordVendorPayment.perform(seller: seller2, payment_params: {payment_method: "cash", order_ids: [order2.id, order3.id]})

    payment = Payment.first
    expect(payment.payment_type).to eq("seller payment")
  end
end
