module FinancialOverviewHelpers
  def deliver_order(order)
    order.items.each do |item|
      item.delivery_status = "delivered"
      order.save!
    end
  end

  def pay_order(order)
    order.payment_status = "paid"
    order.save!
  end

  def financial_row(title)
    Dom::Admin::Financials::MoneyIn.find_by_title(title)
  end
end

RSpec.configure do |config|
  config.include FinancialOverviewHelpers
end
