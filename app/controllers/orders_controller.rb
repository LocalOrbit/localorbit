class OrdersController < ApplicationController
  before_action :require_selected_market
  before_action :require_market_open
  before_action :require_current_organization, except: [:show]
  before_action :require_organization_location, except: [:show]
  before_action :require_current_delivery, except: [:show]
  before_action :require_cart
  before_action :hide_admin_navigation

  before_action :require_cart, only: :create
  before_action :hide_admin_navigation, only: [:create]

  def show
    @order = BuyerOrder.find(current_user, params[:id])
  end

  def create
    if params[:prev_discount_code] != params[:discount_code]
      @apply_discount = ApplyDiscountToCart.perform(cart: current_cart, code: params[:discount_code])
      flash[:discount_message] = @apply_discount.context[:message]
      redirect_to cart_path
    else
      @placed_order = PlaceOrder.perform(entity: current_cart.organization, buyer: current_user, order_params: order_params, cart: current_cart)

      if @placed_order.context.key?(:order)
        @order = @placed_order.order.decorate
      end

      if @placed_order.success?
        session.delete(:cart_id)
        @grouped_items = @order.items.for_checkout
      else
        @grouped_items = current_cart.items.for_checkout

        if @placed_order.context.key?(:cart_is_empty)
          redirect_to [:products], alert: @placed_order.message
        else
          flash.now[:alert] = "Your order could not be completed."
          render "carts/show"
        end
      end
    end
  end

  protected

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
        :save_for_future
      ]
    )
  end
end
