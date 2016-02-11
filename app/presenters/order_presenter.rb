module OrderPresenter
  include TotalsPresenter

  def self.included(base)
    base.class_eval do
      attr_reader :items
      delegate :id, :delivery, :billing_organization_name, :billing_address, :billing_city,
               :billing_state, :billing_zip, :billing_phone, :delivery_address, :delivery_city,
               :delivery_state, :delivery_zip, :delivery_fees,
               :invoice_due_date, :invoiced_at, :invoiced?, :market, :notes, :order_number,
               :organization, :payment_method, :payment_note, :payment_status, :placed_at,
               to: :@order
    end
  end

  def grouped_items
    @items.group_by do |item|
      item.seller_name
    end
  end

  # todo add method to determine what order item id is THE order item
  # then controller will do the order item find
  # save it in an instance variable in the show route so it can be rendered
  # inst variable that can be passed into that view
  # which should then be renderable in the modal

  # hitting order item controller edit method
  # in that controller, there would be a method to 

  # call the show in the orderitems controller with that id that you get via edit link
  # add show -- that does find by id
  # basically puts in @order_item that would be used in the view for rendering the modal form
  # so basically that edit link calls the route for the show in order_item
  # maybe write an edit also? can show edit them? it should go to the modal

  # define a custom order_edit route 
  # is in routes -- orders/order_items
  # should be able to validate this route with a view renderable in orders that references the order_item route when modal form is rendered

  def display_delivery_fees?(user)
    user.admin? || user.market_manager? || user.buyer_only?
  end

  def buyer_payment_status
    @order.payment_status
  end

  def errors
    @order.errors
  end

  def items_attributes=(_)
  end

  def refund?
    ["ach", "credit card"].include?(@order.payment_method) && refund_for_changes && refund_for_changes > 0
  end

  def refund_for_changes
    @refund_for_changes ||= begin
      if @order.audits.present?
        total_cost_update = @order.audits.last.audited_changes["total_cost"]

        if total_cost_update.present?
          total_cost_update[0] - total_cost_update[1]
        end
      end
    end
  end
end
