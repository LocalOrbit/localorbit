class ReportPresenter
  include Search::DateFormat

  attr_reader :report, :items, :fields, :filters, :q, :totals, :start_date, :end_date,
              :markets, :sellers, :buyers, :products, :categories, :payment_methods,
              :fulfillment_days, :fulfillment_types

  FIELD_MAP = {
    placed_at:              {sort: :created_at,              display_name: "Placed On"},
    category_name:          {sort: :product_category_name,   display_name: "Category"},
    product_name:           {sort: :name,                    display_name: "Product"},
    seller_name:            {sort: :seller_name,             display_name: "Seller"},
    buyer_name:             {sort: :order_organization_name, display_name: "Buyer"},
    market_name:            {sort: :order_market_name,       display_name: "Market"},
    quantity:               {sort: :quantity,                display_name: "Quantity"},
    unit_price:             {sort: :unit_price,              display_name: "Unit Price"},
    discount:               {sort: :discount,                display_name: "Actual Discount"},
    row_total:              {sort: nil,                      display_name: "Total"},
    net_sale:               {sort: nil,                      display_name: "Net Sale"},
    payment_method:         {sort: :order_payment_method,    display_name: "Payment Method"},
    delivery_status:        {sort: :delivery_status,         display_name: "Delivery"},
    buyer_payment_status:   {sort: nil,                      display_name: "Buyer Payment Status"},
    seller_payment_status:  {sort: nil,                      display_name: "Seller Payment Status"},
    fulfillment_day:        {sort: :order_delivery_delivery_schedule_day, display_name: "Week Day"},
    fulfillment_type:       {sort: nil,                      display_name: "Fulfillment Type"},
    discount_code:          {sort: nil,                      display_name: "Discount Code"},
    discount_amount:        {sort: nil,                      display_name: "Discount Amount"}
  }.with_indifferent_access

  REPORT_MAP = {
    total_sales: {
      filters: [:placed_at, :order_number, :market_name],
      fields: [
        :placed_at, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
      ]
    },
    sales_by_seller: {
      filters: [:placed_at, :order_number, :market_name, :seller_name],
      fields: [
        :placed_at, :category_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
      ]
    },
    sales_by_buyer: {
      filters: [:placed_at, :order_number, :market_name, :buyer_name],
      fields: [
        :placed_at, :buyer_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
      ]
    },
    sales_by_product: {
      filters: [:placed_at, :order_number, :market_name, :category_name, :product_name],
      fields: [
        :placed_at, :category_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
      ]
    },
    sales_by_payment_method: {
      filters: [:placed_at, :order_number, :market_name, :payment_method],
      fields: [
        :placed_at, :buyer_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :net_sale, :payment_method, :delivery_status, :buyer_payment_status, :seller_payment_status
      ]
    },
    purchases_by_product: {
      filters: [:placed_at, :order_number, :market_name, :category_name, :product_name],
      fields: [
        :placed_at, :category_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :delivery_status, :buyer_payment_status
      ],
      buyer_only: true
    },
    total_purchases: {
      filters: [:placed_at, :order_number, :market_name],
      fields: [
        :placed_at, :product_name, :seller_name, :quantity, :unit_price, :discount,
        :row_total, :delivery_status, :buyer_payment_status
      ],
      buyer_only: true
    },
    sales_by_fulfillment: {
      filters: [:placed_at, :market_name, :buyer_name, :fulfillment_day, :fulfillment_type],
      fields: [
        :placed_at, :fulfillment_day, :fulfillment_type, :buyer_name, :product_name, :seller_name,
        :quantity, :unit_price, :discount, :row_total, :net_sale, :delivery_status,
        :buyer_payment_status, :seller_payment_status
      ]
    },
    discount_code_use: {
      filters: [:placed_at, :order_number, :market_name],
      fields: [
        :placed_at, :buyer_name, :discount_code, :discount_amount, :discount, :net_sale
      ]
    }
  }.with_indifferent_access

  def self.buyer_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:buyer_only] }
  end

  def self.seller_reports
    REPORT_MAP.keys.reject {|k| REPORT_MAP[k][:buyer_only] }
  end

  def initialize(report:, user:, search: {}, paginate: {})
    search ||= {}

    @report = report
    @fields = REPORT_MAP[@report].fetch(:fields, [])
    @filters = REPORT_MAP[@report].fetch(:filters, [])

    # Set our initial scope and lookup any applicable filter data
    items = if self.class.buyer_reports.include?(report)
      OrderItem.for_user_purchases(user)
    else
      OrderItem.for_user(user)
    end.joins(:order).uniq

    # Filter items by discount for the Discount Code report
    items = items.joins(order: :discount) if report == "discount_code_use"

    setup_filter_data(items)

    # Initialize ransack and set a default sort order
    query = Search::QueryDefaults.new(search, :order_placed_at).query
    @q = items.search(query)
    @q.sorts = "created_at desc" if @q.sorts.empty?

    @start_date = format_date(query["order_placed_at_date_gteq".to_s])
    @end_date = format_date(query["order_placed_at_date_lteq".to_s])

    items = @q.result
    @totals = OrderTotals.new(items)

    unless paginate[:csv]
      items = items.
                page(paginate[:page]).
                per(paginate[:per_page])
    end

    @items = include_associations(items)
  end

  def self.report_for(report:, user:, search: {}, paginate: {})
    return nil unless user && reports_for_user(user).include?(report)

    valid = !user.buyer_only? || reports_for_user(user).include?(report)

    new(report: report, user: user, search: search, paginate: paginate) if valid
  end

  def self.reports_for_user(user)
    if user.is_seller_with_purchase?
      seller_reports + buyer_reports
    elsif user.buyer_only?
      buyer_reports
    else
      seller_reports
    end
  end

  def self.field_headers_for_report(report)
    fields = REPORT_MAP[report].fetch(:fields, [])
    Hash[fields.map {|f| [f, FIELD_MAP[f][:display_name]] }]
  end

  private

  def setup_filter_data(items)
    if includes_filter?(:market_name)
      @markets = Market.select(:id, :name).where(id: items.pluck("orders.market_id")).order(:name).uniq
    end

    if includes_filter?(:seller_name)
      @sellers = Organization.select(:id, :name).where(id: items.joins(:product).pluck("products.organization_id")).order(:name).uniq
    end

    if includes_filter?(:buyer_name)
      @buyers = Organization.select(:id, :name).where(id: items.pluck("orders.organization_id")).order(:name).uniq
    end

    if includes_filter?(:category_name)
      @categories = Category.select(:id, :name).where(id: items.joins(:product).pluck("products.category_id")).order(:name).uniq
    end

    if includes_filter?(:product_name)
      # Products have a high chance of duplication so we'll be filtering by
      # string search/matching rather than model ID
      @products = items.pluck(:name).sort_by {|s| s.downcase }.uniq
    end

    if includes_filter?(:payment_method)
      @payment_methods = Order.joins(:items).merge(items).uniq.pluck(:payment_method).sort
    end

    if includes_filter?(:fulfillment_day)
      @fulfillment_days = Hash[DeliverySchedule::WEEKDAYS.map.with_index { |day, index| [index, day] }]
    end

    if includes_filter?(:fulfillment_type)
      @fulfillment_types = DeliverySchedule.joins(deliveries: { orders: :items }).merge(items).all.decorate.map do |ds|
                             key = if ds.fulfillment_type == "Delivery: From Seller to Buyer"
                               "S2B"
                             elsif ds.fulfillment_type == "Delivery: From Market to Buyer"
                               "M2B"
                             else
                               ds.buyer_pickup_location_id
                             end

                             [key, ds.fulfillment_type]
                           end.uniq.sort do |a, b|
                             a[1] <=> b[1]
                           end
    end
  end

  def include_associations(items)
    # All reports use attributes from order
    items = items.includes(:order)

    if includes_field?(:seller_name)
      items = items.includes(product: :organization)
    end

    if includes_field?(:buyer_name)
      # buyer name shows buyer and market so we load both associations
      items = items.includes(order: [:market, :organization])
    end

    if includes_field?(:category_name)
      items = items.includes(product: :category)
    end

    if includes_field?(:fulfillment_type) || includes_field?(:fulfillment_day)
      items = items.includes(order: { delivery: :delivery_schedule })
    end

    items
  end

  def includes_field?(field)
    REPORT_MAP[@report].fetch(:fields, []).include?(field)
  end

  def includes_filter?(filter)
    REPORT_MAP[@report].fetch(:filters, []).include?(filter)
  end
end
