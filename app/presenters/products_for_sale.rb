class ProductsForSale
  def initialize(delivery, buyer, cart, filters={}, options={})
    @delivery = delivery
    @buyer    = buyer
    @cart     = cart
    @filters  = filters
    @options  = options
    @market   = cart.market
  end

  def each_category_with_products
    Category.nested_set_scope.where(id: product_groups.keys).each do |category|
      yield(category, product_groups[category.id])
    end
  end

  def product_groups
    @product_groups ||= products.group_by {|p| p.second_level_category_id }
  end

  def filter_categories
    @filter_categories ||= Category.where(id: pre_filter_products.map(&:top_level_category_id).uniq)
  end

  def filter_organizations
    @filter_organizations ||= @market.organizations.selling.where(id: pre_filter_products.map(&:organization_id).uniq)
  end

  def featured_promotion
    promotion = @market.featured_promotion(@buyer)
    @featured_promotion ||= promotion.decorate(context: {current_cart: @cart}) if promotion
  end

  def products
    return @products if @products

    scope = base_products_scope
    scope = scope.where(id: @options[:product_id]) if @options[:product_id]

    scope = scope.periscope(@filters).decorate(context: {current_cart: @cart})

    @products = with_enough_inventory(scope)
  end

  protected

  def base_products_scope
    scope = @delivery.products_available_for_sale(@buyer).includes(:unit, :category, :prices, :lots).order(:name)

    if @options[:seller]
      scope.where(organization_id: @options[:seller])
    else
      scope
    end
  end

  def pre_filter_products
    @pre_filter_products ||= with_enough_inventory(base_products_scope)
  end

  def with_enough_inventory(products)
    products.select do |product|
      inventory = product.available_inventory(@delivery.deliver_on)
      product.prices.any? {|price| price.for_market_and_organization?(@market, @buyer) && price.min_quantity <= inventory }
    end
  end
end
