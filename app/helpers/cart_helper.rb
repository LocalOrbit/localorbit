module CartHelper
  def allow_payment_option?(field)
    current_market[field] && current_organization[field]
  end
end
