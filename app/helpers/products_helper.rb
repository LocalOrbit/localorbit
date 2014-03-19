module ProductsHelper
  def product_listing_disclaimer
    if @product.prices.count < 1 and @product.lots.count < 1
      condition = "you add inventory and pricing"
    elsif @product.lots.count < 1
      condition = "you add inventory"
    elsif @product.prices.count < 1
      condition = "you add pricing"
    end

    if @product.errors.full_messages.present?
      errors = "you fix the following errors:"
    end

    if condition.present? && errors.present?
      content_tag(:div, "Your product will not appear in the Shop until #{condition}, and #{errors}", class: "product-status-alert")
    elsif errors.present?
      content_tag(:div, "Your product will not appear in the Shop until #{errors}", class: "product-status-alert")
    elsif condition.present?
      content_tag(:div, "Your product will not appear in the Shop until #{condition}.", class: "product-status-alert")
    end
  end

  def us_states
    Country["US"].states.map do |key, state|
      next if %w[AA AK AE AP AS GU MP PR UM VI].include?(key)
      [state["name"], key]
    end.compact
  end
end
