class CreateSellerPaymentForOrders
  include Interactor

  def perform
    seller       = Organization.find(seller_id)
    bank_account = seller.bank_accounts.find(bank_account_id)
    orders       = SellerOrder.find(seller, order_ids)

    context[:payment] = Payment.create(
        orders:         orders,
        bank_account:   bank_account,
        payee:          seller,
        payment_type:   "seller payment",
        amount:         orders.sum {|o| o.payable_to_seller },
        status:         "pending",
        payment_method: "ach"
    )

    context[:recipients] = market.managers.map(&:pretty_email)
  end
end

