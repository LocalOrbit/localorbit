class MarketMailer < BaseMailer

  def fresh_sheet(market, recipients=nil, preview=false)
    @preview        = preview
    @market         = market
    @delivery       = market.next_delivery.decorate
    @product_groups = Product.available_for_market(market).available_for_sale(market).
                              group_by {|p| p.category.self_and_ancestors.find_by(depth: 2).id }
    @categories     = Category.where(depth: 2, id: @product_groups.keys)

    mail(
      to: recipients,
      subject: "See what's fresh this week!"
    )
  end
end
