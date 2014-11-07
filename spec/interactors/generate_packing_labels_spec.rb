describe GeneratePackingLabels, wip:true do
  let(:market) { create(:market) }

  let!(:buyer) { create(:organization, :buyer, name: "Big Money", markets: [market]) }
  let!(:seller) { create(:organization, :seller, name: "Good foodz", markets: [market]) }
  let!(:product1) { create(:product, :sellable, name: "Giant Carrots", organization: seller) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule, deliver_on: 2.days.from_now) }
  let!(:order_items) do
    [
      create(:order_item, product: product1, seller_name: seller.name, name: product1.name, unit_price: 6.50, quantity: 5, quantity_delivered: 0, unit: "stuff", market_seller_fee: 0.75, delivery_status: "canceled", payment_status: "refunded"),
    ]
  end

  let!(:order) { create(:order, items: order_items, organization: buyer, market: market, delivery: delivery, order_number: "LO-ADA-0000001", total_cost: order_items.sum(&:gross_total)) }
  subject { described_class }

  product_info_object = {
    product_name: "Giant Carrots",
    unit_desc: "stuff",
    quantity: 5,
    lot_desc: "Lot #2",
    producer_name: "Good foodz"
  }

  order_info = {
    deliver_on: 2.days.from_now.strftime("%B %e, %Y"),
    order_number: "LO-ADA-0000001",
    buyer_name: "Big Money",
    market_logo_url: "",
    qr_code_url: "",
  }

  full_order_info = order_info.merge({products: [product_info_object]})

  order_label_object = {
    template: "avery_labels/order",
    data: {
      order: order_info,
    }
  }

  product_label_object = {
    template: "avery_labels/vertical_product",
    data: {
      order: order_info,
      product: product_info_object
    }
  }

  it "works by creating order infos, labels, and then pages" do
    s = subject
    expect(s).to receive(:make_order_infos).and_return([full_order_info])
    expect(s).to receive(:make_labels).and_return([order_label_object, product_label_object])
    expect(s).to receive(:make_pages).and_return([{
      a: order_label_object,
      b: product_label_object
    }])
    context = s.perform(delivery: nil, request: double(:request, :base_url=>"/admin/delivery_tools/deliveries/1/packing_labels"))
    expect(context.pdf_result.data.match(/^%PDF-1.4/)).to_not eq nil
  end

  describe "#make_order_info" do
    it "creates an order_infos structure for a given order" do
      expect(GeneratePackingLabels.make_order_infos(delivery)).to eq [full_order_info]
    end
  end
end
