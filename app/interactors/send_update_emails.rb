class SendUpdateEmails
  include Interactor

  def perform
    #return if Rails.env.production?

    #if users_should_be_updated?
    #  OrderMailer.delay.buyer_order_updated(order)
    #end

    #if order.is_localeyes_order?

      order.sellers_with_changes.each do |seller|
        unless seller.users.empty?

          @pack_lists = OrdersBySellerPresenter.new(order.items, seller)
          @delivery = Delivery.find(order.delivery.id).decorate

          OrderMailer.delay(priority: 10).seller_order_updated(order, seller)
        end
      end

      order.sellers_with_cancel.each do |seller|
        unless seller.users.empty?
          @pack_lists = OrdersBySellerPresenter.new(order.items, seller)
          @delivery = Delivery.find(order.delivery.id).decorate

          begin
            pdf = PackingLists::Generator.generate_pdf(request: request, pack_lists: @pack_lists, delivery: @delivery) if !@pack_lists.sellers.empty?
          rescue RuntimeError => e
            pdf = nil
            Rollbar.error(e, 'Failed to generate packing list PDF for seller order item removed email', order_id: order.id)
          end

          csv = PackingLists::Generator.generate_csv(pack_lists: @pack_lists) if !@pack_lists.sellers.empty?

          OrderMailer.delay(priority: 10).seller_order_item_removal(order, seller, pdf, csv)
        end
      end


  #end

    #unless order.market.managers.empty?
    #  OrderMailer.delay.market_manager_order_updated(order)
    #end
  end

  def users_should_be_updated?
    uuid = order.audits.last.try(:request_uuid)

    if uuid.present?
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").
        select {|audit| audit.audited_changes["quantity"].present?}.any? &&
        order.organization.users.any?
    else
      false
    end
  end

  def users_should_be_updated_on_remove?
    uuid = order.audits.last.try(:request_uuid)

    if uuid.present?
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").
          select {|audit| !audit.audited_changes["quantity"].present? || audit.audited_changes["quantity"][1] == 0 || audit.action == :destroy
      }.any? &&
          order.organization.users.any?
    else
      false
    end
  end

end
