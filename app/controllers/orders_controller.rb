class OrdersController < ApplicationController
  before_action :require_selected_market
  before_action :require_market_open,            only: :create
  before_action :require_current_organization,   only: :create
  before_action :require_organization_location,  only: :create
  before_action :require_current_delivery,       only: :create
  before_action :require_cart,                   only: :create
  before_action :hide_admin_navigation,          only: :create

  def show
    @order = BuyerOrder.find(current_user, params[:id])
    track_event EventTracker::ViewedOrder.name, order: { url: order_url(id: @order.id), value: @order.order_number }
  end

  def create
    if params[:prev_discount_code] != params[:discount_code]
      @apply_discount = ApplyDiscountToCart.perform(cart: current_cart, code: params[:discount_code])
      flash[:discount_message] = @apply_discount.context[:message]
      redirect_to cart_path
    elsif order_number_missing?
      reject_order "Your order cannot be completed without a purchase order number."
    else
       @placed_order = PaymentProvider.place_order(current_market.payment_provider,
                                                   buyer_organization: current_cart.organization,
                                                   user: current_user,
                                                   order_params: order_params,
                                                   cart: current_cart)

      if @placed_order.context.key?(:order)
        @order = @placed_order.order.decorate
      end

      if @placed_order.success?
        session.delete(:cart_id)
        @grouped_items = @order.items.for_checkout
      else
        if @placed_order.context.key?(:cart_is_empty)
          @grouped_items = current_cart.items.for_checkout
          redirect_to [:products], alert: @placed_order.message
        else
          reject_order "Your order could not be completed."
        end
      end
    end
  end

  # add this here so it's not just the admin path
  # TODO make sure that a LE buyer's edit directs to a page we can see
  def update
    if current_user.is_localeyes_buyer?
      order = Order.find(params[:id])
      setup_deliveries(order)

      if params["items_to_add"]
        return unless perform_add_items(order)
      elsif params[:commit] == "Add Items"
        show_add_items_form(order)
        return
      elsif params[:commit] == "Change Delivery"
        update_delivery(order)
        return
      end

      # TODO: Change an order items delivery status to 'removed' or something rather then deleting them
      perform_order_update(order, order_params)
    else
      render_404
    end
  end


  protected

  def order_number_missing?
    order_params[:payment_method] == "purchase order" && order_params[:payment_note] == "" && current_market.require_purchase_orders
  end

  def reject_order(message)
    @grouped_items = current_cart.items.for_checkout
    flash.now[:alert] = message
    render "carts/show"
  end

  def order_params
    params.require(:order).permit(
      :discount_code,
      :payment_method,
      :payment_note,
      :bank_account,
      credit_card: [
        :id,
        :name,
        :last_four,
        :expiration_month,
        :expiration_year,
        :bank_name,
        :account_type,
        :balanced_uri,
        :stripe_tok,
        :save_for_future,
        :notes
      ]
    )
  end
end
