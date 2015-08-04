class ProductsForSale
  def initialize(delivery, buyer, cart, filters={}, options={})
    @delivery = delivery
    @buyer    = buyer
    @cart     = cart
    @filters  = filters
    @options  = options
    @market   = cart.market
  end

  def current_page
    (@filters[:page] || 1).to_i
  end

  def total_pages
    # The relation is grouped, so I can't just do a .count. This is faster than
    # getting a .length on unpaged_products.all would be.
    @total_results ||= unpaged_products.count.keys.length
    @total_results / limit_value
  end

  def limit_value
    (@filters[:per_page] || 10).to_i
  end

  def each_category_with_products
    # products.pluck(:category).unique.each do |category|
    #   yield(category, product_groups[category.id])
    # end
    Category.nested_set_scope.where(id: product_groups.keys).each do |category|
      yield(category, product_groups[category.id])
    end
    # first_category = products.first.category
    # yield(first_category, product_groups[first_category.id])
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

  def unpaged_products
    @delivery.products_available_for_sale(@buyer).order(:name)
  end

  def base_products_scope
    scope = unpaged_products.page(current_page).per(limit_value).includes(:unit, [:prices=>:organization], :lots)

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
    products
    # products.select do |product|
    #   inventory = product.available_inventory(@delivery.deliver_on)
    #   product.prices.any? {|price| price.for_market_and_organization?(@market, @buyer) && price.min_quantity <= inventory }
    # end
  end
end
