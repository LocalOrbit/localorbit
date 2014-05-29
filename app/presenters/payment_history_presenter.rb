class PaymentHistoryPresenter
  attr_reader :payments, :q, :start_date, :end_date

  include Search::DateFormat

  def self.build(user: user, organization: organization, options: options)
    page = options[:page]
    per_page = options[:per_page]
    search = options[:q]

    scope = if user.admin?
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
      Payment.joins(:order_payments)
        .includes(:orders)
        .where(orders: {organization_id: organization.id})
        .where("orders.payment_status = ? OR (orders.payment_method = ? AND payments.status = ?)", "paid", "ach", "pending")
    else
      Payment.where(payee: organization)
    end

    payments = scope.order("payments.updated_at DESC")

    new(payments, search, page, per_page)
  end

  def initialize(payments, search, page, per_page)
    @start_date = format_date(search.try(:fetch, :updated_at_date_gteq))
    @end_date = format_date(search.try(:fetch, :updated_at_date_lteq))

    @q = payments.search(search)
    @payments = @q.result.page(page).per(per_page)
  end
end
