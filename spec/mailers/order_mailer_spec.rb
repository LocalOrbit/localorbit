require 'spec_helper'

describe OrderMailer do
  let!(:market)            { create(:market) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery)          { create(:delivery, delivery_schedule: delivery_schedule) }
  let!(:supplier1)         { create(:organization, :seller, name: 'Grandville Farms', markets: [market]) }
  let!(:supplier2)         { create(:organization, :seller, name: 'Zeeland Farms', markets: [market]) }
  let!(:buyer)             { create(:organization, :buyer, name: 'Hudsonville Restaurant', markets: [market]) }
  let!(:users)             { create_list(:user, 2, organizations: [supplier1]) }
  let!(:buyer_user)        { create(:user, :buyer, organizations: [buyer]) }

  let!(:product1)          { create(:product, :sellable, organization: supplier1) }
  let!(:product2)          { create(:product, :sellable, organization: supplier2) }

  let!(:order)             { create(:order, market: market, delivery: delivery, delivery_fees: 3, placed_by: buyer_user, organization: buyer, payment_method: 'ach', total_cost: 30.0) }
  let!(:order_item1)       { create(:order_item, order: order, product: product1, quantity: 11, unit_price: 2.00) }
  let!(:order_item2)       { create(:order_item, order: order, product: product2, quantity: 4, unit_price: 2.50) }

  let!(:csv)               { 'CSV' }

  describe '.seller_confirmation' do
    let(:notification) { OrderMailer.seller_confirmation(order.reload, supplier1) }

    it 'delivers to all users in the organization' do
      expect(notification).to deliver_to(users.map(&:email))
    end

    it 'shows the seller what order the notification relates to' do
      expect(notification).to have_body_text("Order Number: #{order.order_number}")
    end

    it 'shows what market the order is from' do
      expect(notification).to have_subject("New order on #{market.name}")
    end

    it 'shows what buyer made the order' do
      expect(notification).to have_body_text(
        "An order was just placed by <strong>#{buyer.name}</strong>"
      )
    end

    it 'shows how the seller should view the order details' do
      expect(notification).to have_body_text("following the link below and logging in to your #{supplier1.name} account")
    end

    it 'does not show a previous quantity for an item' do
      within('.previous-value') do
        expect(notification).to_not have_body_text('11 per box')
      end
    end

    it 'does not show delivery fee' do
      expect(notification).not_to have_body_text('Delivery Fee')
    end
  end

  describe '.buyer_confirmation' do
    let(:notification) { OrderMailer.buyer_confirmation(order) }

    it 'shows the delivery fee' do
      expect(notification).to have_body_text('Delivery Fee')
    end
  end

  describe '.buyer_order_updated' do
    context 'quantities changed' do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 15}})
        OrderItem.disable_auditing
        Order.disable_auditing
        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.buyer_order_updated(order.reload)
      end

      it 'has a subject indicating it is an update' do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} Updated")
      end

      it 'shows the old order quantity' do
        expect(@notification).to have_body_text('11 per box')
      end

      it 'shows the updated order quantity' do
        expect(@notification).to have_body_text('15 per box')
      end
    end

    context 'canceled items' do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 0, delivery_status: 'canceled'}})
        OrderItem.disable_auditing
        Order.disable_auditing

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.buyer_order_updated(order.reload)
      end

      it 'has a subject indicating it is an update' do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} Updated")
      end

      it 'shows canceled items quantity as 0' do
        expect(@notification).to have_body_text('0 per box')
      end

      it 'does not show the canceled items previous quantity' do
        expect(@notification).to_not have_body_text('11 per box')
      end

      it 'shows the item as being canceled' do
        expect(@notification).to have_body_text('canceled')
      end
    end

    context 'refund amount' do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 5}})
        OrderItem.disable_auditing
        Order.disable_auditing

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.buyer_order_updated(order.reload)
      end

      it 'shows the refund amount' do
        expect(@notification).to have_body_text('refund of $3.00')
      end
    end

    context 'increasing the quantity' do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 15}})
        OrderItem.disable_auditing
        Order.disable_auditing

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.buyer_order_updated(order.reload)
      end

      it 'does not show the refund section' do
        expect(@notification).to_not have_body_text('refund')
      end
    end
  end

  describe '.seller_order_updated' do
    let(:notification) { OrderMailer.seller_order_updated(order, supplier_org) }

    context 'quantities changed' do
      let(:supplier_org) { supplier1 }

      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 15}})
        OrderItem.disable_auditing
        Order.disable_auditing

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.seller_order_updated(order.reload, supplier1)
      end

      it 'has a subject indicating it is an update' do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} Updated")
      end

      it 'shows the old order quantity' do
        expect(@notification).to have_body_text('11 per box')
      end

      it 'shows the updated order quantity' do
        expect(@notification).to have_body_text('15 per box')
      end

      it 'does not show other seller items' do
        expect(@notification).to_not have_body_text(product2.name)
      end
    end

    context 'canceled items' do
      let(:supplier_org) { supplier1 }

      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 0, delivery_status: 'canceled'}})
        OrderItem.disable_auditing
        Order.disable_auditing

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.seller_order_updated(order.reload, supplier1)
      end

      it 'has a subject indicating it is an update' do
        expect(@notification).to have_subject("#{market.name}: Order #{order.order_number} Updated")
      end

      it 'shows canceled items quantity as 0' do
        expect(@notification).to have_body_text('0 per box')
      end

      it 'shows the item as being canceled' do
        expect(@notification).to have_body_text('canceled')
      end

      it 'does not show the canceled items previous quantity' do
        expect(@notification).to_not have_body_text('10 per box')
      end

      it 'does not show other seller items' do
        expect(@notification).to_not have_body_text(product2.name)
      end
    end

    xcontext 'refund amount' do
      let(:supplier_org) { supplier1 }

      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 5}})
        OrderItem.disable_auditing
        Order.disable_auditing
        pdf = PdfResult.new(data: 'data', path: '/')

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.seller_order_updated(order.reload, supplier1)
      end

      it 'shows the refund amount' do
       expect(@notification).to have_body_text('refund of $3.00')
      end
    end

    context 'increasing the quantity' do
      before do
        Order.enable_auditing
        OrderItem.enable_auditing
        order.reload.update(updated_at: Time.current, items_attributes: {'0' => {id: order_item1.id, quantity: 15}})
        OrderItem.disable_auditing
        Order.disable_auditing

        Audit.all.update_all(request_uuid: SecureRandom.uuid)
        @notification = OrderMailer.seller_order_updated(order.reload, supplier1)
      end

      it 'does not show the refund section' do
        expect(@notification).to_not have_body_text('refund')
      end
    end

    context 'when supplier org has no users' do
      let(:supplier_org) { create(:organization, :seller, markets: [market]) }

      it 'no email is sent' do
        expect { notification }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    context 'when supplier org has only unconfirmed users' do
      let(:supplier_org)      { create(:organization, :seller, markets: [market]) }
      let!(:unconfirmed_users) { create_list(:user, 2, confirmed_at: nil, organizations: [supplier_org]) }

      it 'no email is sent' do
        expect { notification }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    context 'when supplier org has both confirmed and unconfirmed users' do
      let(:supplier_org)       { create(:organization, :seller, markets: [market]) }
      let!(:confirmed_user1)   { create(:user, confirmed_at: Time.now, organizations: [supplier_org]) }
      let!(:confirmed_user2)   { create(:user, confirmed_at: Time.now, organizations: [supplier_org]) }
      let!(:unconfirmed_user1) { create(:user, confirmed_at: nil, organizations: [supplier_org]) }

      it 'email is sent to only confirmed users' do
        expect(notification).to be_delivered_to([confirmed_user1.email, confirmed_user2.email])
      end
    end
  end

  describe '.invoice' do
    let(:notification) { OrderMailer.invoice(order.id) }

    it 'delivers to all users in the buyer organization' do
      expect(notification).to be_delivered_to(buyer_user.email)
    end
  end
end
