class CartsController < ApplicationController
  before_action :require_market_open
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart
  before_action :hide_admin_navigation
  before_action :set_payment_provider

  def show
    @order_type = session[:order_type]
    respond_to do |format|
      format.html do
        errors ||= []
        if current_cart.items.empty?
          target = 'products'
          target += '_purchase' if @order_type == 'purchase'

          redirect_to [target.to_sym], alert: "Your cart is empty. Please add items to your cart before checking out."
        else
          current_cart.items.each do |item|
            invalid = validate_qty(item, @order_type)
            errors << invalid if invalid

            if invalid then
              if invalid[:actual_count] > 0 then
                item.update(quantity: invalid[:actual_count])
              else
                item.update(quantity: 0)
                item.destroy
              end
            end
          end

          flash[:error] = errors.map{|r| r[:error_msg]}.join(". ") if errors.count > 0

          @grouped_items = current_cart.items.for_checkout

          if !flash.now[:discount_message] && current_cart.discount.present?
            @apply_discount = ApplyDiscountToCart.perform(cart: current_cart, code: current_cart.discount.code)
            flash.now[:discount_message] = @apply_discount.context[:message]
          end
        end
      end
      format.json do
        total = if current_cart then current_cart.items.count else 0 end
        render json: {:total=>total}
      end
    end
  end

  def update
    product = Product.includes(:prices).find(params[:product_id])
    delivery_date = current_delivery.deliver_on

    @item = current_cart.items.find_or_initialize_by(product_id: product.id)

    if params[:quantity].to_i > 0
      @item.quantity = params[:quantity]
      @item.sale_price = params[:sale_price]
      @item.net_price = params[:net_price]
      @item.lot_id = params[:lot_id]
      @item.product = product

      if @order_type == "sales" && @item.quantity && @item.quantity > 0 && @item.quantity > product.available_inventory(delivery_date, current_market.id, current_organization.id)
        @error = "Quantity of #{product.name} available for purchase: #{product.available_inventory(delivery_date, current_market.id, current_organization.id)}"
        @item.quantity = product.available_inventory(delivery_date, current_market.id, current_organization.id)
      end

      @error = @item.errors.full_messages.join(". ") unless @item.save
    elsif @item.persisted?
      @item.update(quantity: 0)
      @item.destroy
    end

    flash[:error] = @error unless !@error
    @apply_discount = current_cart.discount ? ApplyDiscountToCart.perform(cart: current_cart, code: current_cart.discount.code) : nil
  end

  # add Delivery Note deletion to cart's destroy
  def destroy
    DeliveryNote.where(cart_id:current_cart.id).each do |dn|
      DeliveryNote.soft_delete(dn.id) 
    end
    current_cart.destroy
    session.delete(:cart_id)
    redirect_to [:products]
  end

  protected

  def validate_qty(item, order_type)
    error = nil
    if order_type == "sales"
      product = Product.includes(:prices).find(item.product.id)
      delivery_date = current_delivery.deliver_on
      actual_count = product.available_inventory(delivery_date, current_market.id, current_organization.id)

      if item.quantity && item.quantity > 0 && item.quantity > actual_count
        error = {
          item_id: item.id,
          error_msg: "Quantity of #{product.name} (#{product.unit.plural}) available for purchase: #{product.available_inventory(delivery_date, current_market.id, current_organization.id)}",
          actual_count: actual_count
        }
      end
    end
    error
  end

  private

  def set_payment_provider
    @payment_provider = current_market.payment_provider
  end
end
