module FinancialOverviewHelpers
  def deliver_order(order, payment=nil)
    order.items.each do |item|
      item.delivery_status = "delivered"
      order.save!
    end
  end

  def pay_order(order)
    order.payment_status = "paid"
    order.save!
  end

  def money_in_row(title)
    Dom::Admin::Financials::MoneyIn.find_by_title(title)
  end

  def money_out_row(title)
    Dom::Admin::Financials::MoneyOut.find_by_title(title)
  end
end

RSpec.configure do |config|
  config.include FinancialOverviewHelpers
end
