module Admin::Financials
  class BuyerPaymentsController < AdminController
    def index
      @payments = Payment.joins(:order_payments)
        .includes(:orders)
        .where(orders: {organization_id: current_organization.id, payment_status: 'paid'})
        .decorate
    end
  end
end
