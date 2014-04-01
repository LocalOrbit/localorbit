class StoreOrderFees
  include Interactor

  def perform
    calculate_fees
    cap_fees
    order.items.each(&:save!)
  end

  protected

  def calculate_fees
    order.items.map {|item| fees_for(item) }
  end

  def cap_fees
    return unless order.payment_method == 'ach'

    total = order.items.map {|item| item.payment_seller_fee + item.payment_market_fee }.sum
    if total > order.market.ach_fee_cap
      order.items.each do |item|
        item.payment_seller_fee = order.market.ach_fee_cap * item.payment_seller_fee / total
        item.payment_market_fee = order.market.ach_fee_cap * item.payment_market_fee / total
      end
    end
  end

  def fees_for(item)
    item.market_seller_fee      = item.gross_total * order.market.market_seller_fee / 100
    item.local_orbit_seller_fee = item.gross_total * order.market.local_orbit_seller_fee / 100
    item.local_orbit_market_fee = item.gross_total * order.market.local_orbit_market_fee / 100

    if order.payment_method == 'credit card'
      item.payment_seller_fee = item.gross_total * order.market.credit_card_seller_fee / 100
      item.payment_market_fee = item.gross_total * order.market.credit_card_market_fee / 100
    elsif order.payment_method == 'ach'
      item.payment_seller_fee = item.gross_total * order.market.ach_seller_fee / 100
      item.payment_market_fee = item.gross_total * order.market.ach_market_fee / 100
    end
  end
end