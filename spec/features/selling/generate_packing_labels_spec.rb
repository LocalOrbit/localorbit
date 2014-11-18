require "spec_helper"

context "Downloading packing labels", js:true do
  let(:plan_with_packing_labels) { create(:plan, :nothing, packing_labels: true) }
  let(:market) { create(:market, plan: plan_with_packing_labels) }

  let!(:buyer) { create(:organization, :buyer, name: "Big Money", markets: [market]) }
  let!(:seller) { create(:organization, :seller, name: "Good foodz", markets: [market]) }
  let(:user) { create(:user, organizations: [seller])}
  let!(:seller2) { create(:organization, :seller, name: "Better foodz", markets: [market]) }
  let!(:product1) { create(:product, :sellable, name: "Green things", organization: seller) }
  let!(:product2) { create(:product, :sellable, name: "Purple cucumbers", organization: seller) }
  let!(:product3) { create(:product, :sellable, name: "Brocolli", organization: seller2) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule, deliver_on: 2.days.from_now) }
  let!(:order_items) do
    [
      create(:order_item, product: product1, seller_name: seller.name, name: product1.name, unit_price: 6.50, quantity: 5, quantity_delivered: 0, unit: "Bushels", market_seller_fee: 0.75, delivery_status: "canceled", payment_status: "refunded"),
      create(:order_item, product: product2, seller_name: seller.name, name: product2.name, unit_price: 5.00, quantity: 10, quantity_delivered: 10, unit: "Lots", payment_seller_fee: 1.20),
      create(:order_item, product: product3, seller_name: seller2.name, name: product3.name, unit_price: 2.00, quantity: 12, unit: "Heads", local_orbit_seller_fee: 4)
    ]
  end

  let!(:order) { create(:order, items: order_items, organization: buyer, market: market, delivery: delivery, order_number: "LO-ADA-0000001", total_cost: order_items.sum(&:gross_total)) }

  before(:each) do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  it "lets users generate shipping labels as a PDF document" do
    visit admin_delivery_tools_path
    expect(page).to have_text "Upcoming Deliveries"

    expect(page).to have_text "Labels"

    find(".app-labels-link").click

    expect(page).to have_text("Generating packing labels...")

    patiently do
      uid = current_path[1..-1]
      order_printably = PackingLabelsPrintable.find_by(pdf_uid: uid)
      expect(order_printably).to be
      expect(order_printably.pdf).to be
      expect(order_printably.pdf.file).to be
      expect(order_printably.pdf.file.readlines.first).to match(/PDF-1\.4/)
    end
  end

end
