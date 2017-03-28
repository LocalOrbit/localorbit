class OrdersController < ApplicationController
  include StickyFilters
  include Inventory

  before_action :require_selected_market
  before_action :require_market_open,            only: :create
  before_action :require_current_organization,   only: :create
  before_action :require_organization_location,  only: :create
  before_action :require_current_delivery,       only: :create
  before_action :require_cart,                   only: :create
  before_action :hide_admin_navigation,          only: :create
  before_action :find_sticky_params, only: [:index, :purchase_orders]

  def index
    po_filter = {:q => {"order_type_matches" => 'sales'}}
    @query_params.merge!(po_filter)

    order_list
  end

  def purchase_orders
    po_filter = {:q => {"order_type_eq" => "purchase"}}
    @query_params.merge!(po_filter)

    order_list

    render :index
  end

  def order_list
    @query_params["placed_at_date_gteq"] ||= 7.days.ago.to_date.to_s
    @query_params["placed_at_date_lteq"] ||= Date.today.to_s
    @presenter = BuyerOrderPresenter.new(current_user, current_market, request.query_parameters, @query_params)
    @q = search_and_calculate_totals(@presenter)

    @buyer_orders ||= @q.result
    @buyer_orders = @buyer_orders.page(params[:page]).per(@query_params[:per_page])
  end

  def show
    @order = BuyerOrder.find(current_user, params[:id])

    if current_market.is_consignment_market?
      load_consignment_transactions(@order)
      load_open_po
    end

    track_event EventTracker::ViewedOrder.name, order: { url: order_url(id: @order.id), value: @order.order_number }
  end

  def create
    @order_type = session[:order_type]
    # Validate cart items against current inventory...
    errors ||= []
    current_cart.items.each do |item|
      invalid = validate_qty(item)
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

    # ...and redirect to cart if there isn't quantity to fill order
    if errors.count > 0 then
      flash[:error] = errors.map{|r| r[:error_msg]}.join(". ")
      redirect_to cart_path and return
    end

    if params[:prev_discount_code] != params[:discount_code]
      @apply_discount = ApplyDiscountToCart.perform(cart: current_cart, code: params[:discount_code])
      flash[:discount_message] = @apply_discount.context[:message]
      redirect_to cart_path
    elsif order_number_missing?
      reject_order "Your order cannot be completed without a purchase order number."
    else
      @placed_order = PaymentProvider.place_order(
        current_market.payment_provider,
        buyer_organization: current_cart.organization,
        user: current_user,
        order_params: order_params,
        cart: current_cart, request: request
      )

      if @placed_order.context.key?(:order)
        @order = @placed_order.order.decorate
      end

      if @placed_order.success?
        session.delete(:cart_id)
        session.delete(:current_organization_id)
        session.delete(:current_supplier_id)
        session.delete(:current_delivery_id)
        session.delete(:current_delivery_day)
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

  protected

  def validate_qty(item)
    error = nil
    if current_market.is_buysell_market?
      product = Product.includes(:prices).find(item.product.id)
      delivery_date = current_delivery.deliver_on
      actual_count = product.available_inventory(delivery_date, current_market.id, current_organization.id, item.lot_id)

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
      :order_type,
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

  def search_and_calculate_totals(query)
    results = Order.includes(:organization, :items, :delivery).orders_for_buyer(current_user).search(query.query)
    results.sorts = "placed_at desc" if results.sorts.empty?

    results
  end

=begin
  def load_consignment_transactions(order)
    @child_transactions = []
    @po_transactions = ConsignmentTransaction.joins("
      LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
      LEFT JOIN products ON consignment_transactions.product_id = products.id
      LEFT JOIN order_items ON consignment_transactions.order_item_id = order_items.id")
                           .where(order_id: order.id, transaction_type: 'PO')
                           .where("parent_id IS NULL")
                           .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.product_id, products.name as product_name, lots.number as lot_name, order_items.delivery_status, consignment_transactions.quantity, consignment_transactions.net_price, consignment_transactions.sale_price")
                           .order("consignment_transactions.id, consignment_transactions.parent_id")

    if !@po_transactions.nil?
      @po_transactions.each do |po|
        ct = ConsignmentTransaction.joins("
        LEFT JOIN orders ON consignment_transactions.order_id = orders.id
        LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
        LEFT JOIN organizations ON orders.organization_id = organizations.id")
                 .where(parent_id: po.id)
                 .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.order_id, consignment_transactions.product_id, consignment_transactions.quantity, lots.number as lot_name, consignment_transactions.net_price, consignment_transactions.sale_price, organizations.name AS buyer_name, orders.delivery_status")
                 .order("consignment_transactions.product_id, consignment_transactions.created_at")

        @child_transactions << ct.to_a
      end
    end

    @parent_transactions = []
    @so_transactions = ConsignmentTransaction.joins("
        LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
        LEFT JOIN products ON consignment_transactions.product_id = products.id
        LEFT JOIN order_items ON consignment_transactions.order_item_id = order_items.id")
                           .where(order_id: order.id, transaction_type: 'SO')
                           .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.product_id, products.name as product_name, lots.number as lot_name, lots.quantity as lot_quantity, order_items.delivery_status, consignment_transactions.quantity, consignment_transactions.net_price, consignment_transactions.sale_price, consignment_transactions.parent_id")
                           .order("consignment_transactions.id, consignment_transactions.parent_id")


    if !@so_transactions.nil?
      @so_transactions.each do |so|
        ct = ConsignmentTransaction.joins("
            LEFT JOIN orders ON consignment_transactions.order_id = orders.id
            LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
            LEFT JOIN organizations ON orders.organization_id = organizations.id")
                 .where(id: so.parent_id)
                 .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.order_id, consignment_transactions.product_id, consignment_transactions.quantity, lots.number as lot_name, consignment_transactions.net_price, consignment_transactions.sale_price, organizations.name AS buyer_name, orders.delivery_status")
                 .order("consignment_transactions.product_id, consignment_transactions.created_at")

        @parent_transactions << ct.to_a
      end
    end
  end
=end
end
