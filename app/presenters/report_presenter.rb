class ReportPresenter
  attr_reader :report, :items, :fields, :q, :markets, :sellers, :buyers

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
    row_total:              { sort: nil,                      display_name: "Row Total" },
    net_sale:               { sort: nil,                      display_name: "Net Sale" },
    delivery_status:        { sort: :delivery_status,         display_name: "Delivery" },
    buyer_payment_status:   { sort: :order_payment_status,    display_name: "Buyer Payment Status" },
    seller_payment_status:  { sort: nil,                      display_name: "Seller Payment Status" }
  }.with_indifferent_access

  REPORT_FIELD_MAP = {
    total_sales: [
      :placed_at, :product_name, :seller_name, :quantity, :unit_price, :discount,
      :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
    ],
    sales_by_seller: [
      :placed_at, :category_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
      :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
    ],
    sales_by_buyer: [
      :placed_at, :buyer_name, :product_name, :seller_name, :quantity, :unit_price, :discount,
      :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
    ]
  }.with_indifferent_access

  def self.reports
    REPORT_FIELD_MAP.keys
  end

  def self.field_headers_for_report(report)
    fields = REPORT_FIELD_MAP[report] || []
    Hash[fields.map { |f| [f, FIELD_MAP[f][:display_name]] }]
  end

  def initialize(report:, user:, search: {}, paginate: {})
    @report = report

    # TODO: includes appropriate associations based on report
    items = OrderItem.for_user(user).joins(:order)

    # Initialize ransack and set a default sort order
    @q = items.search(search)
    @q.sorts = "created_at desc" if @q.sorts.empty?

    @items = @q.result.page(paginate[:page]).per(paginate[:per_page])
    @markets = Market.for_order_items(items)
    @sellers = items.pluck(:seller_name).uniq
    @buyers = Organization.buyers_for_order_items(items)
    @fields = REPORT_FIELD_MAP[report]
  end
end
