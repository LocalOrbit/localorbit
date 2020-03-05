class ReportPresenter
  include Search::DateFormat

  attr_reader :report, :items, :fields, :filters, :q, :totals, :start_date, :end_date,
              :markets, :sellers, :buyers, :products, :categories, :payment_methods,
              :fulfillment_days, :fulfillment_types, :lots

  FIELD_MAP = {
    placed_at:              {sort: :created_at,              display_name: "Placed On"},
    delivered_at:           {sort: :delivered_at,            display_name: "Delivered On"},
    category_name:          {sort: :product_category_name,   display_name: "Category"},
    subcategory_name:       {sort: :subcategory_name,        display_name: "Subcategory"},
    product_name:           {sort: :name,                    display_name: "Product"},
    seller_name:            {sort: :seller_name,             display_name: "Supplier"},
    buyer_name:             {sort: :order_organization_name, display_name: "Buyer"},
    market_name:            {sort: :order_market_name,       display_name: "Market"},
    quantity:               {sort: :quantity,                display_name: "Quantity"},
    unit_price:             {sort: :unit_price,              display_name: "Unit Price"},
    unit:                   {sort: :unit_name,               display_name: "Unit"},
    discount:               {sort: :discount,                display_name: "Actual Discount"},
    row_total:              {sort: nil,                      display_name: "Total"},
    fee_pct:                {sort: nil,                      display_name: "Fee"},
    profit:                 {sort: nil,                      display_name: "Profit"},
    net_sale:               {sort: nil,                      display_name: "Net Sale"},
    payment_method:         {sort: :order_payment_method,    display_name: "Payment Method"},
    delivery_status:        {sort: :delivery_status,         display_name: "Delivery"},
    buyer_payment_status:   {sort: nil,                      display_name: "Buyer Payment Status"},
    seller_payment_status:  {sort: nil,                      display_name: "Supplier Payment Status"},
    fulfillment_day:        {sort: :order_delivery_delivery_schedule_buyer_day, display_name: "Week Day"},
    fulfillment_type:       {sort: nil,                      display_name: "Fulfillment Type"},
    discount_code:          {sort: nil,                      display_name: "Discount Code"},
    discount_amount:        {sort: nil,                      display_name: "Discount Amount"},
    product_code:           {sort: :code,                    display_name: "Product Code"},
    lot_info:               {sort: :expires_at,              display_name: "Lot"}
    # TODO add all needed fields for lot report with display name here
  }.with_indifferent_access

  REPORT_MAP = {
    total_purchases: {
        filters: [:placed_at, :order_number, :market_name],
        fields: [
            :placed_at, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit,
            :row_total, :delivery_status, :buyer_payment_status, :seller_payment_status
        ],
        buyer_only: true,
        le_mm: true
    },
    purchases_by_product: {
        filters: [:placed_at, :order_number, :market_name, :category_name, :subcategory_name, :product_name],
        fields: [
            :placed_at, :category_name, :subcategory_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
            :row_total, :delivery_status, :buyer_payment_status
        ],
        buyer_only: true,
        le_mm: true
    },
    purchases_by_buyer: {
        filters: [:placed_at, :order_number, :market_name, :buyer_name],
        fields: [
            :placed_at, :buyer_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
            :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
        ],
        le_mm: true
    },
    purchases_by_supplier: {
        filters: [:placed_at, :order_number, :market_name, :seller_name],
        fields: [
            :placed_at, :category_name, :subcategory_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
            :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
        ],
        le_mm: true
    },
    total_sales: {
        filters: [:placed_at, :order_number, :market_name],
        fields: [
            :placed_at, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
            :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
        ],
        seller_only: true
    },
    sales_by_supplier: {
      filters: [:placed_at, :order_number, :market_name, :seller_name, :product_name],
      fields: [
        :placed_at, :category_name, :subcategory_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
        :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
      ],
      mm_only: true,
      ex_ss: true,
    },
    sales_by_buyer: {
      filters: [:placed_at, :deliver_on, :order_number, :market_name, :buyer_name],
      fields: [
        :placed_at, :buyer_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
        :row_total, :net_sale, :delivery_status, :buyer_payment_status, :seller_payment_status
      ],
      seller_only: true
    },
    sales_by_product: {
      filters: [:placed_at, :order_number, :market_name, :category_name, :subcategory_name, :product_name, :seller_name],
      fields: [
        :placed_at, :category_name, :subcategory_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
        :row_total, :net_sale, :fee_pct, :profit, :delivery_status, :buyer_payment_status, :seller_payment_status
      ],
      seller_only: true
    },
    sales_by_payment_method: {
      filters: [:placed_at, :order_number, :market_name, :payment_method],
      fields: [
        :placed_at, :buyer_name, :product_name, :product_code, :seller_name, :quantity, :unit_price, :unit, :discount,
        :row_total, :net_sale, :payment_method, :delivery_status, :buyer_payment_status, :seller_payment_status
      ],
      seller_only: true
    },
    sales_by_fulfillment: {
      filters: [:placed_at, :market_name, :buyer_name, :fulfillment_day, :fulfillment_type],
      fields: [
        :placed_at, :fulfillment_day, :fulfillment_type, :buyer_name, :product_name, :product_code, :seller_name,
        :quantity, :unit_price, :unit, :discount, :row_total, :net_sale, :delivery_status,
        :buyer_payment_status, :seller_payment_status
      ],
      mm_only: true,
      ex_mm: true
    },
    discount_code_use: {
      filters: [:placed_at, :order_number, :market_name],
      fields: [
        :placed_at, :buyer_name, :discount_code, :discount_amount, :discount, :net_sale
      ],
      mm_only: true,
      ex_mm: true
    },
    lots: {
      filters: [:lot_number, :market_name, :seller_name, :product_name, :placed_at],
      fields: [:lot_info, :seller_name, :placed_at, :delivered_at, :buyer_name, :category_name, :subcategory_name, :product_name
        ],
      use_adv_inventory: true
    }
  }.with_indifferent_access

  def self.buyer_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:buyer_only] }
  end

  def self.seller_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:seller_only]}
  end

  def self.mm_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:mm_only]}
  end

  def self.lot_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:use_adv_inventory]}
  end

  def self.exclude_mm_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:ex_mm]}
  end

  def self.exclude_ss_reports
    REPORT_MAP.keys.select {|k| REPORT_MAP[k][:ex_ss]}
  end

  def initialize(report:, market:, user:, search: {}, paginate: {})
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

    setup_filter_data(items, market, user)

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

  def self.report_for(report:, market:, user:, search: {}, paginate: {})
    return nil unless user && reports_for_user(user, market).include?(report)

    valid = !user.buyer_only? || reports_for_user(user, market).include?(report)

    new(report: report, market: market, user: user, search: search, paginate: paginate) if valid
  end

  def self.reports_for_user(user, market)
    if user.admin?
      seller_reports + buyer_reports + mm_reports
    elsif user.is_seller_with_purchase?
      seller_reports + buyer_reports
    elsif user.buyer_only?
      buyer_reports
    elsif user.market_manager?
      reports = nil
      if !Pundit.policy!(user, :all_supplier).index?
        reports = seller_reports + mm_reports - exclude_ss_reports
      else
        reports = seller_reports + mm_reports
      end
      if Pundit.policy!(user, :advanced_inventory).index?
        reports = reports + lot_reports
      end
      reports
    else
      seller_reports
    end
  end

  def self.field_headers_for_report(report)
    fields = REPORT_MAP[report].fetch(:fields, [])
    Hash[fields.map {|f| [f, FIELD_MAP[f][:display_name]] }]
  end

  private

  def setup_filter_data(items, market, user)
    if includes_filter?(:market_name)
      @markets = Market.select(:id, :name).where(id: items.pluck("orders.market_id")).order(:name).uniq
    end

    if includes_filter?(:seller_name)
      @sellers = Organization.
                   select(:id, :name).
                   where(org_type: Organization::TYPE_SUPPLIER,
                         id: items.joins(:product).pluck("products.organization_id")).
                   order(:name).
                   uniq
    end

    if includes_filter?(:buyer_name)
      @buyers = Organization.
                  active.
                  select(:id, :name).
                  where(id: items.pluck("orders.organization_id")).
                  order(:name).
                  uniq
    end

    if includes_filter?(:category_name)
      @categories = Category.select(:id, :name).where(depth: [1..2], id: items.joins(:product).pluck("products.category_id")).order(:name).uniq
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

    if includes_filter?(:expired_on_or_after)
      # @dates = Lot.joins(:items).merge(items).uniq.pluck(:expires_at).sort # probably
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

    # Below: additions for lot reporting
    if includes_field?(:lot_info)
      items = items.includes(:lots)
    end

    ## TODO: Possible this information can be drawn from the lot, in-view, if all lots for a given OrderItem are known ^

    if includes_field?(:expired_on_or_after)
    end

    if includes_field?(:good_from)
    end

    if includes_field?(:remaining_inventory)
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
