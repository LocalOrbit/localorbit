class AttemptPurchaseOrderPurchase
  include Interactor

  def perform
    if order_params["payment_method"] == "purchase order"
      # noop for now
    end
  end
end
