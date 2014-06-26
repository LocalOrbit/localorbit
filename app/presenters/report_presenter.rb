class ReportPresenter
  attr_reader :report, :items, :fields, :filters, :q, :totals,
    :markets, :sellers, :buyers, :products, :categories, :payment_methods

  FIELD_MAP = {
    placed_at:              { sort: :created_at,              display_name: "Placed On" },
    category_name:          { sort: :product_category_name,   display_name: "Category" },
    product_name:           { sort: :name,                    display_name: "Product" },
    seller_name:            { sort: :seller_name,             display_name: "Seller" },
    buyer_name:             { sort: :order_organization_name, display_name: "Buyer" },
    market_name:            { sort: :order_market_name,       display_name: "Market" },
    quantity:               { sort: :quantity,                display_name: "Quantity" },
    unit_price:             { sort: :unit_price,              display_name: "Unit Price" },
    discount:               { sort: :discount,                display_name: "Discount" },
    row_total:              { sort: nil,                      display_name: "Total" },
    net_sale:               { sort: nil,                      display_name: "Net Sale" },
    payment_method:         { sort: :order_payment_method,    display_name: "Payment Method" },
    delivery_status:        { sort: :delivery_status,         display_name: "Delivery" },
    buyer_payment_status:   { sort: :order_payment_status,    display_name: "Buyer Payment Status" },
    seller_payment_status:  { sort: nil,                      display_name: "Seller Payment Status" }
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
    }
  }.with_indifferent_access

  def initialize(report:, user:, search: {}, paginate: {})
    search ||= {}

    @report = report
    @fields = REPORT_MAP[@report].fetch(:fields, [])
    @filters = REPORT_MAP[@report].fetch(:filters, [])

    # Set our initial scope and lookup any applicable filter data
    items = OrderItem.for_user(user).joins(:order).uniq
    setup_filter_data(items)

    # Initialize ransack and set a default sort order
    @q = items.search(search)
    @q.sorts = "created_at desc" if @q.sorts.empty?

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
    return nil unless user && self.reports.include?(report)

    valid = if user.admin?
              true
            elsif user.buyer_only?
              if self.reports(buyer_only: true).include?(report)
                true
              end
            elsif (self.reports - self.reports(buyer_only: true)).include?(report)
              true
            end

    new(report: report, user: user, search: search, paginate: paginate) if valid
  end

  def self.reports_for_user(user)
    self.reports(buyer_only: user.try(:buyer_only?))
  end

  def self.reports(buyer_only: false)
    if buyer_only
      REPORT_MAP.keys.select { |k| REPORT_MAP[k][:buyer_only] }
    else
      REPORT_MAP.keys
    end
  end

  def self.field_headers_for_report(report)
    fields = REPORT_MAP[report].fetch(:fields, [])
    Hash[fields.map { |f| [f, FIELD_MAP[f][:display_name]] }]
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
      @products = items.pluck(:name).sort_by { |s| s.downcase }.uniq
    end

    if includes_filter?(:payment_method)
      @payment_methods = Order.joins(:items).merge(items).uniq.pluck(:payment_method).sort
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

    items
  end

  def includes_field?(field)
    REPORT_MAP[@report].fetch(:fields, []).include?(field)
  end

  def includes_filter?(filter)
    REPORT_MAP[@report].fetch(:filters, []).include?(filter)
  end
end
