class CaptureCreditCardHold
  include Interactor

  def perform
    begin
      hold = Balanced::Hold.find(payment.balanced_uri)
      if hold.debit.present?
        fail!(error: "Funds already captured from credit card")
        return
      end

      debit = hold.capture(
        appears_on_statement_as: "LOMarketPurchase",
        description: "LocalOrbit Market Purchase"
      )

      if debit.status == "succeeded"
        payment.update(status: "paid", balanced_uri: debit.uri)
      else
        fail!(error: "Unable to capture credit card funds")
      end

    rescue
      fail!(error: "Unable to capture credit card funds")
    end

  end

end
