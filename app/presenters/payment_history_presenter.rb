class PaymentHistoryPresenter
  attr_reader :payments, :q, :start_date, :end_date, :payers, :payees

  include Search::DateFormat

  def self.build(user: user, options: options, paginate: true)
    page = options[:page]
    per_page = options[:per_page]
    search = options[:q] || {}

    payments = if user.admin?
      Payment.all
    elsif user.market_manager?
      payment_table = Payment.arel_table
      order_payment_table = OrderPayment.arel_table
      order_table = Order.arel_table

      market_ids = user.managed_market_ids

      Payment.joins(
        payment_table.join(order_payment_table, Arel::Nodes::OuterJoin).
          on(order_payment_table[:payment_id].eq(payment_table[:id])).join_sources
      ).joins(
        order_payment_table.join(order_table, Arel::Nodes::OuterJoin).
          on(order_payment_table[:order_id].eq(order_table[:id])).join_sources
      ).where(
          order_table[:market_id].in(market_ids).
        or(
          payment_table[:payer_type].eq("Market").
          and(payment_table[:payer_id].in(market_ids))).
        or(
          payment_table[:payee_type].eq("Market").
          and(payment_table[:payee_id].in(market_ids)))
      ).uniq
    elsif user.buyer_only?
      Payment.
        joins(:orders).
        where(payer_type: "Organization", payer_id: (user.organization_ids)).
        where("orders.payment_status = ? OR (orders.payment_method = ? AND payments.status = ?)", "paid", "ach", "pending")
    else
      Payment.where(payee: user.organizations)
    end

    new(payments, search, page, per_page, paginate)
  end

  def initialize(payments, query, page, per_page, paginate=true)
    search = Search::QueryDefaults.new(query, :created_at).query

    @start_date = format_date(search[:created_at_date_gteq])
    @end_date = format_date(search[:created_at_date_lteq])

    # Initialize ransack and set a default sort order
    @q = payments.search(search)
    @q.sorts = "created_at desc" if @q.sorts.empty?

    @payments = @q.result
    @payments = @payments.page(page).per(per_page) if paginate

    @payers = options_for_payments(payments, :payer)
    @payees = options_for_payments(payments, :payee)
  end

  private

  def options_for_payments(payments, payment_attribute)
    case payment_attribute
    when :payer
      payments.map do |payment|
        if payment.payer.nil?
          ["Local Orbit", -1]
        else
          [payment.payer.name, "#{payment.payer_type}#{payment.payer_id}"]
        end
      end.uniq.compact
    when :payee
      payments.map do |payment|
        if payment.payee.nil?
          ["Local Orbit", -1]
        else
          [payment.payee.name, "#{payment.payee_type}#{payment.payee_id}"]
        end
      end.uniq.compact
    end
  end
end
