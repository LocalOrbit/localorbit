class CreateSellerPaymentForOrders
  include Interactor

  def perform
    seller        = Organization.find(seller_id)
    bank_account  = seller.bank_accounts.find(bank_account_id)
    group         = SellerPaymentGroup.new(seller, Order.where(id: order_ids))

    context[:payment] = Payment.create(
        orders:         group.unwrapped_orders,
        bank_account:   bank_account,
        payee:          seller,
        payment_type:   "seller payment",
        amount:         group.owed,
        status:         "pending",
        payment_method: "ach"
    )

    context[:recipients] = seller.users.map(&:pretty_email)
  end
end
