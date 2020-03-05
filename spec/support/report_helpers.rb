module ReportHelpers
  def follow_buyer_order_link(order:nil, order_number:nil)
    order ||= Order.find_by(order_number: order_number)
    raise "Need :order or :order_number" unless order

    follow_order_link order: order

    # (cheat: peek at the path to see we're on buyer version of the page:)
    order_path = order_path(order)
    expect(page.current_path).to eq(order_path)
  end

  def follow_admin_order_link(order:nil, order_number:nil)
    order ||= Order.find_by(order_number: order_number)
    raise "Need :order or :order_number" unless order

    follow_order_link order: order

    # (cheat: peek at the path to see we're on buyer version of the page:)
    expect(page.current_path).to eq(admin_order_path(order))
  end

  def follow_order_link(order:)
    page.first("a", text: order.order_number).click

    expect(page.status_code).not_to eq(404)
    expect(page).not_to have_content("We can't find that page")
    expect(page).not_to have_content("The Market Is Currently Closed")

    expect(page).to have_content("Order info for #{order.order_number}")
    expect(page).to have_content("Payment Method:")
    expect(page).to have_content("Delivery Status:")
  end

  #
  # Links to Orders:
  #

  def see_admin_order_link(order:)
    expect(page).to have_link(order.order_number, href: admin_order_path(order))
  end

  def see_buyer_order_link(order:)
    expect(page).to have_link(order.order_number, href: order_path(order))
  end

  #
  # Links to Products:
  #

  def see_admin_product_link(product:)
    expect(page).to have_link(product.name, href: admin_product_path(product))
  end

  def see_buyer_product_link(product:)
    expect(page).to have_link(product.name, href: product_path(product))
  end

  #
  # Links to Sellers:
  #

  def see_admin_seller_link(seller:)
    expect(page).to have_link(seller.name, href: admin_organization_path(seller))
  end

  def see_buyer_seller_link(seller:)
    expect(page).to have_link(seller.name, href: seller_path(seller))
  end
end

RSpec.configure do |config|
  config.include ReportHelpers
end
