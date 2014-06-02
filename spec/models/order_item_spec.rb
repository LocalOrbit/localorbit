require 'spec_helper'

describe OrderItem do
  let(:product) { create(:product, lots: [
        create(:lot, quantity: 3),
        create(:lot, quantity: 5)
      ]
  )}

  let(:order) { build(:order, market: create(:market)) }

  context "changing quantity delivered" do
    subject { OrderItem.new(seller_name: "Fennington Farms", unit: create(:unit), name: product.name, product: product, quantity: 8, delivery_status: 'pending') }

    it "sets the delivery status to 'delivered' when a positive quantity delivered" do
      subject.quantity_delivered = 9
      subject.save!

      expect(subject.reload.delivery_status).to eql('delivered')
    end

    it "sets the delivery status to 'canceled' when a quantity delivered of 0" do
      subject.quantity_delivered = 0
      subject.save!

      expect(subject.reload.delivery_status).to eql('canceled')
    end

    it "does not override 'contested'" do
      subject.delivery_status = "contested"
      subject.quantity_delivered = 9
      subject.save!

      expect(subject.reload.delivery_status).to eql('contested')
    end
  end

  context "changing deliver status" do
    subject { OrderItem.new(seller_name: "Fennington Farms", unit: create(:unit), name: product.name, product: product, quantity: 8) }

    it "sets delivered_at date when changed to 'delivered'" do
      expect(subject.delivery_status).to be_nil
      expect(subject.delivered_at).to be_nil

      Timecop.freeze do
        subject.delivery_status = "delivered"
        subject.save!

        expect(subject.delivered_at).to eql(Time.current)
      end

    end

    it "sets quantity_delivered when changed to 'delivered'" do
      subject.delivery_status = "delivered"
      subject.save!

      expect(subject.reload.quantity_delivered).to eql(8)
    end

    it "sets quantity_delivered to 0 when changed to 'canceled'" do
      subject.delivery_status = "canceled"
      subject.save!

      expect(subject.reload.quantity_delivered).to eql(0)
    end
  end

  context "validations" do
    it "requires a name" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:name)
    end

    it "requires a seller name" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:seller_name)
    end

    it "requires a unit" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:unit)
    end

    it "requires a unit_price" do
      subject.unit_price = nil
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:unit_price)
    end

    it "requires a quantity" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:quantity)
    end

    it "required a product" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:product)
    end

    it "does not require a quantity_delivered" do
      expect(subject).to_not have(1).error_on(:quantity_delivered)
    end

    it "require a quantity_delivered to be greater than 0" do
      subject.quantity_delivered = -1
      expect(subject).to have(1).error_on(:quantity_delivered)
    end

    it "require a quantity_delivered to be less than 2,147,483,647" do
      subject.quantity_delivered = 2_147_483_648
      expect(subject).to have(1).error_on(:quantity_delivered)
    end


    describe "product_availability" do
      context "quantity is not present" do
        it "only shows the error for quantity" do
          expect(subject).to have(1).error_on(:quantity)
          expect(subject).to have(:no).errors_on(:inventory)
        end
      end

      context "no product" do
        subject { OrderItem.new(product: nil) }

        it "only shows the error for product presence" do
          expect(subject).to have(:no).errors_on(:inventory)
          expect(subject).to have(1).error_on(:product)
        end
      end

      context "when product and quantity are present" do
        context "and order item quantity is less than or equal to available product inventory" do
          subject { OrderItem.new(product: product, quantity: 8) }

          it "has no inventory errors" do
            expect(subject).to have(:no).errors_on(:inventory)
          end
        end

        context "and order item quantity is greater than available product inventory" do
          subject { OrderItem.new(product: product, quantity: 9) }

          it "has no inventory errors" do
            expect(subject).to have(1).errors_on(:inventory)
          end
        end
      end
    end
  end

  describe ".create" do
    let!(:expired_lot) do
      Timecop.travel(1.day.ago) do
        create(:lot, number: 2, quantity: 10, product: product, expires_at: Time.now + 2.minutes)
      end
    end

    let!(:future_good_from_lot) { create(:lot, number: 3, quantity: 10, product: product, good_from: Time.now + 3.days) }

    def create_valid_order_item
      OrderItem.create!(
        name: "Foo",
        seller_name: "Seller",
        unit: create(:unit),
        order: order,
        product: product,
        delivery_status: "pending",
        quantity: 7
      )
    end

    it "consumes inventory from available lots" do
      expect{
        create_valid_order_item
      }.to change {
        Lot.find(product.lots.map(&:id)).map(&:quantity)
      }.from([3, 5]).to([0, 1])
    end

    it "does not consume inventory from expired lots and lots that are not good yet" do
      expect{
        create_valid_order_item
      }.not_to change{
        Lot.find(expired_lot.id, future_good_from_lot.id).map(&:quantity)
      }
    end

    context "uses oldest expiring lots first" do
      let(:lot1) { build(:lot, quantity: 10)}
      let(:lot2) { build(:lot, number: 2, quantity: 3, expires_at: 1.minute.from_now) }
      let(:lot3) { build(:lot, number: 3, quantity: 7, expires_at: 1.hour.from_now) }
      let(:product2) { create(:product, lots: [lot1, lot2, lot3]) }

      it "decrements lot quantity on OrderItem creation" do
        item = OrderItem.create!(
          deliver_on_date: Date.current,
          name: "Foo",
          seller_name: "Seller",
          unit: create(:unit),
          order: order,
          product: product2,
          delivery_status: "pending",
          quantity: 8
        )

        expect(item).to be_valid
        expect(Lot.find(lot2.id).quantity).to eql(0)
        expect(Lot.find(lot3.id).quantity).to eql(2)
        expect(Lot.find(lot1.id).quantity).to eql(10)
      end
    end
  end

  describe "self.create_with_order_and_item_and_deliver_on_date" do
    let(:market) { create(:market) }
    let(:organization) { create(:organization) }
    let(:product) { create(:product, :sellable) }
    let(:order) { build(:order, market: market, organization: organization) }
    let(:cart_item) { create(:cart_item, product: product) }

    subject { OrderItem.create_with_order_and_item_and_deliver_on_date(order: order, item: cart_item, deliver_on_date: Date.today) }

    it "captures associations" do
      expect(subject.product).to eql(product)
    end

    it "captures the product name" do
      expect(subject.name).to eq(product.name)
    end

    it "captures the seller name" do
      expect(subject.seller_name).to eql(product.organization.name)
    end

    it "captures the unit" do
      expect(subject.quantity).to eql(1)
      expect(subject.unit).to eql(product.unit.singular)
    end

    it "captures the unit price" do
      expect(subject.unit_price).to eql(cart_item.unit_price.sale_price)
    end

    it "captures the quantity" do
      expect(subject.quantity).to eql(cart_item.quantity)
    end

    it "does not set delivered quantity" do
      expect(subject.quantity_delivered).to be_nil
    end

    context "order item is not valid" do
      before do
        cart_item.product.update_attribute(:name, nil)
      end

      it "does not consume inventory" do
        expect {
          subject
        }.not_to change {
          Lot.find(cart_item.product.lots.map &:id).map &:quantity
        }
      end
    end
  end

  context "product inventory" do
    let!(:lot1)          { create(:lot, number: 1, quantity: 10) }
    let!(:product)       { create(:product, :sellable, lots: [lot1]) }
    let!(:market)        { create(:market) }
    let!(:organization)  { create(:organization) }
    let!(:order)         { build(:order, market: market, organization: organization) }
    let(:cart_item)      { create(:cart_item, product: product) }
    let(:deliver_on)     { Date.today }

    subject do
      order_item = OrderItem.create_with_order_and_item_and_deliver_on_date(order: order, item:cart_item, deliver_on_date: deliver_on )
      order_item.order = order
      order_item.save
      order_item
    end

    it 'consumes inventory on creation' do
      expect {
        subject
      }.to change {
        lot1.reload.quantity
      }.from(10).to(9)
    end

    it 'returns inventory on destruction' do
      subject

      expect {
        subject.destroy
      }.to change {
        lot1.reload.quantity
      }.from(9).to(10)
    end
  end

  context "seller_payment_status" do
    let!(:market)      { create(:market) }
    let!(:seller1)     { create(:organization, :seller, name: "Better Farms", markets: [market]) }
    let!(:seller2)     { create(:organization, :seller, name: "Great Farms",  markets: [market]) }
    let!(:buyer)       { create(:organization, :buyer,  name: "Money Bags",   markets: [market]) }
    let!(:product1)    { create(:product, :sellable, organization: seller1) }
    let!(:product2)    { create(:product, :sellable, organization: seller2) }
    let!(:order_item1) { create(:order_item, :delivered, product: product1, quantity: 3) }
    let!(:order_item2) { create(:order_item, :delivered, product: product2, quantity: 7) }
    let!(:order) do
      create(:order,
        items:          [order_item1, order_item2],
        market:         market,
        organization:   buyer,
        payment_method: "purchase order",
        order_number:   "LO-002",
        total_cost:     69.90,
        placed_at:      6.days.ago,
        payment_status: "paid"
      )
    end

    let!(:payments_for_order) { create(:payment, payee: seller2, orders: [order], amount: 48.93) }

    it "seller1 is unpaid" do
      expect(order_item1.seller_payment_status).to eq('Unpaid')
    end

    it "seller2 is paid" do
      expect(order_item2.seller_payment_status).to eq('Paid')
    end
  end
end
