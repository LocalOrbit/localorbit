require "spec_helper"

describe OrderMailer do
  let!(:market)            { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery)          { create(:delivery, delivery_schedule: delivery_schedule) }
  let!(:seller1)           { create(:organization, name: "Grandville Farms", can_sell: true, markets: [market]) }
  let!(:seller2)           { create(:organization, name: "Zeeland Farms", can_sell: true, markets: [market]) }
  let!(:buyer)             { create(:organization, name: "Hudsonville Restraunt", can_sell: false, markets: [market]) }
  let!(:users)             { create_list(:user, 2, organizations: [seller1]) }
  let!(:buyer_user)        { create(:user, organizations: [buyer]) }

  let!(:product1)          { create(:product, :sellable, organization: seller1) }
  let!(:product2)          { create(:product, :sellable, organization: seller2) }

  let!(:order)             { create(:order, market: market, delivery: delivery, placed_by: buyer_user, organization: buyer) }
  let!(:order_item1)       { create(:order_item, order: order, product: product1, quantity: 10) }
  let!(:order_item2)       { create(:order_item, order: order, product: product2, quantity: 5) }

  describe "seller_confirmation" do
    let!(:notification) { OrderMailer.seller_confirmation(order, seller1) }

    it "delivers to all users in the organization" do
      expect(notification).to deliver_to(users.map(&:email))
    end

    it "shows the seller what order the notification relates to" do
      expect(notification).to have_body_text("Order Number: #{order.order_number}")
    end

    it "shows what market the order is from" do
      expect(notification).to have_subject("New order on #{market.name}")
    end

    it "shows what buyer made the order" do
      expect(notification).to have_body_text(
        "An order was just placed by <strong>#{buyer.name}</strong>"
      )
    end

    it "shows how the seller should view the order details" do
      expect(notification).to have_body_text("following the link below and logging in to your #{seller1.name} account")
    end
  end

  describe "buyer_order_updated" do
    context "quantities changed" do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order_item1.update(quantity: 33)
        order.update(updated_at: Time.current)
        OrderItem.disable_auditing
        Order.disable_auditing

        @notification = OrderMailer.buyer_order_updated(order.reload)
      end

      it "has a subject indicating it is an update" do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} updated")
      end

      it "shows the old order quantity" do
        expect(@notification).to have_body_text("10 per box")
      end

      it "shows the updated order quantity" do
        expect(@notification).to have_body_text("33 per box")
      end
    end

    context "canceled items" do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order_item1.update(delivery_status: "canceled")
        order.update(updated_at: Time.current)
        OrderItem.disable_auditing
        Order.disable_auditing

        @notification = OrderMailer.buyer_order_updated(order.reload)
      end

      it "has a subject indicating it is an update" do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} updated")
      end

      it "shows the item as being canceled" do
        expect(@notification).to have_body_text("canceled")
      end
    end
  end

  describe "seller_order_updated" do
    context "quantities changed" do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order_item1.update(quantity: 33)
        order.update(updated_at: Time.current)
        OrderItem.disable_auditing
        Order.disable_auditing

        @notification = OrderMailer.seller_order_updated(order.reload, seller1)
      end

      it "has a subject indicating it is an update" do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} updated")
      end

      it "shows the old order quantity" do
        expect(@notification).to have_body_text("10 per box")
      end

      it "shows the updated order quantity" do
        expect(@notification).to have_body_text("33 per box")
      end

      it "does not show other seller items" do
        expect(@notification).to_not have_body_text(product2.name)
      end
    end

    context "canceled items" do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order_item1.update(delivery_status: "canceled")
        order.update(updated_at: Time.current)
        OrderItem.disable_auditing
        Order.disable_auditing

        @notification = OrderMailer.seller_order_updated(order.reload, seller1)
      end

      it "has a subject indicating it is an update" do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} updated")
      end

      it "shows the item as being canceled" do
        expect(@notification).to have_body_text("canceled")
      end

      it "does not show other seller items" do
        expect(@notification).to_not have_body_text(product2.name)
      end
    end
  end
end
