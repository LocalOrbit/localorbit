class PaymentHistoryPresenter
  attr_reader :payments, :q, :start_date, :end_date

  include Search::DateFormat

  def initialize(user: user, options: options, paginate: true)
    @user = user
    page = options[:page]
    per_page = options[:per_page]
    @query = options[:q] || {}

    search = Search::QueryDefaults.new(query, :created_at).query

    @start_date = format_date(search[:created_at_date_gteq])
    @end_date = format_date(search[:created_at_date_lteq])

    # Initialize ransack and set a default sort order
    @q = payments_for_role.search(search)
    @q.sorts = "created_at desc" if @q.sorts.empty?

    @payments = @q.result
    @payments = @payments.page(page).per(per_page) if paginate
  end

  def payers
    build_options_for_party_filters unless @payers
    @payers
  end

  def payees
    build_options_for_party_filters unless @payees
    @payees
  end

  private

  attr_reader :user, :query

  def payments_for_role
    if user.admin?
      admin_query
    elsif user.market_manager?
      market_manager_query
    elsif user.buyer_only?
      buyer_query
    else
      seller_query
    end
  end

  def admin_query
    Payment.includes(:payee, :payer).all
  end

  def payment_table
    Payment.arel_table
  end

  def order_payment_table
    OrderPayment.arel_table
  end

  def order_table
    Order.arel_table
  end

  def market_manager_query
    market_ids = user.managed_market_ids

    if query[:payee_type_id_in] && query[:payee_type_id_in].include?("-1")
      base_market_manager_query.
      where(order_table[:market_id].in(market_ids).
        and(payment_table[:payee_type].eq(nil).
        and(payment_table[:payee_id].in(market_ids))
        )
      ).uniq
    elsif query[:payer_type_id_in] && query[:payer_type_id_in].include?("-1")
      base_market_manager_query.
      where(order_table[:market_id].in(market_ids).
        and(payment_table[:payer_type].eq(nil).
        and(payment_table[:payer_id].in(market_ids))
        )
      ).uniq
    else
      base_market_manager_query.
      where(
          order_table[:market_id].in(market_ids).
        or(
          payment_table[:payer_type].eq("Market").
          and(payment_table[:payer_id].in(market_ids))).
        or(
          payment_table[:payee_type].eq("Market").
          and(payment_table[:payee_id].in(market_ids)))
      ).uniq
    end
  end

  def base_market_manager_query
    @base_market_manager_query ||= Payment.joins(
      payment_table.join(order_payment_table, Arel::Nodes::OuterJoin).
        on(order_payment_table[:payment_id].eq(payment_table[:id])).join_sources
    ).joins(
      order_payment_table.join(order_table, Arel::Nodes::OuterJoin).
        on(order_payment_table[:order_id].eq(order_table[:id])).join_sources
    )
  end

  def buyer_query
    Payment.
      joins(:orders).
      where(payer_type: "Organization", payer_id: (user.organization_ids)).
      where("orders.payment_status = ? OR (orders.payment_method = ? AND payments.status = ?)", "paid", "ach", "pending")
  end

  def seller_query
    Payment.where(payee: user.organizations)
  end

  def build_options_for_party_filters
    payers_tmp = []
    payees_tmp = []
    Payment.includes(:payer, :payee).where(id: payments_for_role).map do |payment|
      payers_tmp.push(create_option(payment.payer))
      payees_tmp.push(create_option(payment.payee))
    end
    @payers = payers_tmp.compact.uniq.sort_by{|k| k[0] }
    @payees = payees_tmp.compact.uniq.sort_by{|k| k[0] }
  end

  def create_option(party)
    return ['Local Orbit', -1] if party.nil?
    [party.name, "#{party.class}#{party.id}"]
  end

end
