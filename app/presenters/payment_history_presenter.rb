class PaymentHistoryPresenter
  attr_reader :payments, :q, :start_date, :end_date

  def self.build(user: user, organization: organization, options: options)
    page = options[:page]
    per_page = options[:per_page]
    search = options[:q]

    scope = if user.admin?
      Payment.all
    elsif user.market_manager?
      market_ids = user.managed_market_ids

      Payment.joins("left join organizations on organizations.id = payments.payer_id").
        joins("left join market_organizations on market_organizations.organization_id = organizations.id").
        where("market_organizations.market_id in (:market_ids) OR (payments.payer_type = 'Market' AND payments.payer_id in (:market_ids)) OR (payments.payee_type = 'Market' AND payments.payer_id in (:market_ids))", market_ids: market_ids)
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

  private
  def format_date(date_string)
    date_string.present? ? Date.parse(date_string) : nil
  end
end
