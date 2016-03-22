require "spec_helper"

describe ProcessPackingLabelsPrintable do
  subject { described_class }

  ####
  
  let(:admin_user) { create(:user, :admin, name: "Admin user") }

  let(:market) { create(:market) }
  let(:manager) { create(:user, :market_manager, name: "The Manatee", managed_markets: [market]) }

  let!(:buyer) { create(:organization, :buyer, name: "Big Money", markets: [market]) }
  let!(:seller_user) { create(:user, name: "The Seller") }
  let!(:seller42_user) { create(:user, name: "Marvin") }
  let!(:seller) { create(:organization, :seller, name: "Good foodz", markets: [market], users: [seller_user]) }
  let!(:seller42) { create(:organization, :seller, name: "Marvin Gardens", markets: [market], users: [seller42_user]) }
  let!(:product1) { create(:product, :sellable, name: "Giant Carrots", organization: seller) }
  let!(:product2) { create(:product, :sellable, name: "Marvins Beets", organization: seller42) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:deliver_on) { 2.days.from_now }
  let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule, deliver_on: deliver_on) }
  let!(:order_items) do
    [
      create(:order_item, product: product1, seller_name: seller.name, name: product1.name, unit_price: 6.50, quantity: 5, quantity_delivered: 0, unit: "stuff"),
      create(:order_item, product: product2, seller_name: seller42.name, name: product2.name, unit_price: 4.25, quantity: 3, quantity_delivered: 0, unit: "each"),
    ]
  end

  let(:order_number) { "LO-ADA-0000001" }
  let!(:order) { create(:order, items: order_items, organization: buyer, market: market, delivery: delivery, order_number: order_number, total_cost: order_items.sum(&:gross_total)) }


  let!(:seller_user2) { create(:user, name: "The OTHER Seller") }
  let!(:seller2) { create(:organization, :seller, name: "Other Farm", markets: [market], users: [seller_user2]) }
  let!(:buyer2) { create(:organization, :buyer, name: "Small Timer", markets: [market]) }
  let!(:product3) { create(:product, :sellable, name: "Flat Chikkens", organization: seller2) }
  let!(:order_items2) do
    [
      create(:order_item, product: product3, seller_name: seller2.name, name: product3.name, unit_price: 10, quantity: 2, quantity_delivered: 0, unit: "stacks"),
    ]
  end

  let(:order_number2) { "LO-ADA-0000002" }
  let!(:order2) { create(:order, items: order_items2, organization: buyer2, market: market, delivery: delivery, order_number: order_number2, total_cost: order_items2.sum(&:gross_total)) }

  let(:all_orders) { delivery.orders.sort_by(&:billing_organization_name) }
  let(:seller_orders) { [ order ] }
  let(:seller2_orders) { [ order2 ] }

  ####

  let(:admin_printable) { create(:packing_labels_printable, user: admin_user, delivery: delivery) }
  let(:seller_printable) { create(:packing_labels_printable, user: seller_user, delivery: delivery) }
  let(:seller2_printable) { create(:packing_labels_printable, user: seller_user2, delivery: delivery) }
  let(:manager_printable) { create(:packing_labels_printable, user: manager, delivery: delivery) }

  ####

  let(:product_labels_only) { false }
  let(:product_label_format) { 4 }
  let(:print_multiple_labels_per_item) { false }

  # Fake stuff
  let(:context) { double("result context", pdf_result: double("Pdf result", data: "the pdf data"))}
  let(:request) { double "a request" }
  let(:pdf_result) {double("Pdf result", data: "the pdf data")}

  def unfortunately_forcible_reload(obj)
    # Dragonfly's side effects are only observible in this test if we get a fresh new AR instance. :(
    obj.class.find(obj.id)
  end

  def fake_seller_order_for(order)
    "Fake SellerOrder[#{order.id}]"
  end

  def expect_generate_packing_labels_for_orders(orders,user)
    orders.each do |o|
      expect(SellerOrder).to receive(:new).
        with(o, user).
        and_return(fake_seller_order_for(o))
    end

    expect(PackingLabels::Generator).to receive(:generate) do |args|
      expect(args[:request]).to eq request
      expect(args[:orders]).to eq(orders.map do |o| fake_seller_order_for(o) end)
      pdf_result
    end
  end

  def verify_pdf_generated_on(printable)
    printable = unfortunately_forcible_reload(printable)
    expect(printable.pdf.file.read).to eq("the pdf data")
    expect(printable.pdf.name).to eq("delivery_labels.pdf")
  end

  context "an admin" do
    it "loads an PackingLabelsPrintable and generates the corresponding PDF document, stores that PDF as an attachment" do
      expect_generate_packing_labels_for_orders(all_orders, admin_user)

      subject.perform(packing_labels_printable_id: admin_printable.id, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item)

      verify_pdf_generated_on admin_printable
    end
  end

  context "as a seller" do
    it "only includes orders for the specific seller" do
      expect_generate_packing_labels_for_orders(seller_orders,seller_user)

      subject.perform(packing_labels_printable_id: seller_printable.id, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item)

      verify_pdf_generated_on seller_printable
    end
  end

  context "as the OTHER seller" do
    it "only includes orders for the specific seller" do
      expect_generate_packing_labels_for_orders(seller2_orders, seller_user2)

      subject.perform(packing_labels_printable_id: seller2_printable.id, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item)

      verify_pdf_generated_on seller2_printable
    end
  end

  context "as a market manager" do
    it "includes all orders" do
      expect_generate_packing_labels_for_orders(all_orders, manager)

      subject.perform(packing_labels_printable_id: manager_printable.id, request: request, product_labels_only: product_labels_only, product_label_format: product_label_format, print_multiple_labels_per_item: print_multiple_labels_per_item)

      verify_pdf_generated_on manager_printable
    end
  end
end
