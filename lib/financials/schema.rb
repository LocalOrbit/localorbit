module Financials
  module Schema
    Id = Integer

    Money = BigDecimal

    AccountOption = [ String, Id ] # Tuples suitable for the options_for_select Rails view helper

    DeliveryStatus = RSchema::DSL.enum([ nil, "", "Delivered", "Partially Delivered", "Pending", "Cancelled" ])

    PaymentStatus = RSchema::DSL.enum([ "Paid", "Unpaid", "Refunded", "Pending" ])
    PaymentStatusLower = RSchema::DSL.enum([ "paid", "unpaid", "refunded", "pending" ])

    PaymentTypeLower = RSchema::DSL.enum([
                        "delivery fee",
                        "hub fee",
                        "lo fee",
                        "market payment",
                        "order",
                        "order refund",
                        "seller payment",
                        "service",
                        "service refund"])

    PaymentMethod = RSchema::DSL.enum([ "Credit Card", "ACH", "Paypal", "Purchase Order" ])
    PaymentMethodLower = RSchema::DSL.enum([ "credit card", "ach", "paypal", "purchase order" ])


    PaymentInfo = {
      amount:       Money,
      payee:        RSchema::DSL.either(Organization,Market),
      bank_account: BankAccount,
      market:       Market,
      orders:       [Order]
    }

  end
end
