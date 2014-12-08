module Financials
  module Schema
    Id = Integer

    Money = BigDecimal

    AccountOption = [ String, Id ] # Tuples suitable for the options_for_select Rails view helper

    DeliveryStatus = RSchema::DSL.enum([ nil, "", "Delivered", "Partially Delivered", "Pending", "Cancelled" ])

    PaymentStatus = RSchema::DSL.enum([ "Paid", "Unpaid", "Refunded", "Pending" ])

    PaymentMethod = RSchema::DSL.enum([ "Credit Card", "ACH", "Paypal", "Purchase Order" ])
  end
end
