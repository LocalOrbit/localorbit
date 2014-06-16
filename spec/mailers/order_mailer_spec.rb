require "spec_helper"

describe OrderMailer do
  describe "seller_confirmation" do
    let!(:market) { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
    let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule) }
    let!(:seller) { create(:organization, name: "Hudsonville Farms", can_sell: true, markets: [market]) }
    let!(:buyer) { create(:organization, name: "Hudsonville Farms", can_sell: true, markets: [market]) }
    let!(:users) { create_list(:user, 2, organizations: [seller])}
    let!(:buyer_user) { create(:user, organizations: [buyer])}

    let!(:product) { create(:product, :sellable, organization: seller)}

    let!(:order_item) { create(:order_item) }
    let!(:order) { create(:order, market: market, delivery: delivery, placed_by: buyer_user) }
    let!(:notification) { OrderMailer.seller_confirmation(order, seller) }

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
        "An order was just placed by <strong><a href=\"mailto:#{buyer_user.email}\">#{buyer_user.email}</a></strong>"
      )
    end

    it "shows how the seller should view the order details" do
      expect(notification).to have_body_text("following the link below and logging in to your #{seller.name} account")
    end
  end
end

