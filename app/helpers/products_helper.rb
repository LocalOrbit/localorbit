module ProductsHelper
  def can_change_delivery?
    current_market.delivery_schedules.visible.count > 1 || current_organization.locations.count > 1 || current_user.managed_organizations.count > 1
  end

  def can_change_delivery_on_placed_order?(order)
    current_user.can_manage_market?(order.market)
  end

  def inventory_tab_complete?
    @product.available_inventory > 0
  end

  def pricing_tab_complete?
    @product.prices.count > 0
  end

  def product_listing_disclaimer
    condition = []
    if @product.simple_inventory == 0
      condition.push link_to_unless_current "add inventory", [:admin, @product, :lots]
    end

    if @product.prices.count < 1
      condition.push link_to_unless_current "add pricing", [:admin, @product, :prices]
    end

    if @product.errors.full_messages.present?
      condition.push "fix the following errors:"
    end

    if condition.length > 0
      content_tag(:div, "Your product will not appear in the Shop until you #{condition.join(", and ")}".html_safe, class: "product-status-alert")
    end
  end

  def us_states
    Country["US"].states.map do |key, state|
      next if %w(AA AK AE AP AS GU MP PR UM VI).include?(key)
      [state["name"], key]
    end.compact
  end
end
