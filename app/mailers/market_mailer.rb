class MarketMailer < ActionMailer::Base
  layout "email"
  default from: "service@localorb.it"

  def fresh_sheet(market, recipients=nil, preview=false)
    @categories = Category.where(depth: 2)
    @preview        = preview
    @market         = market
    @delivery       = market.next_delivery.decorate
    @product_groups = Product.available_for_market(market).available_for_sale(market).
      group_by {|p| p.category.self_and_ancestors.find_by(depth: 2).id }

    recipients ||= market.organizations.buying.joins(:users).
      where("users.send_freshsheet = ?", true).pluck(:name, :email).
      map {|name, email| "#{name} <#{email}>" }

    mail(
      to: recipients,
      subject: "See what's fresh this week!"
    )
  end
end
