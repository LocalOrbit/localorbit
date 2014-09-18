module ReportHelpers
  def follow_buyer_order_link(order:nil, order_number:nil)
    order ||= Order.find_by(order_number: order_number)
    raise "Need :order or :order_number" unless order

    follow_order_link order: order

    # (cheat: peek at the path to see we're on buyer version of the page:)
    expect(page.current_path).to eq(order_path(order))
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
    
    # See we're not on 404:
    expect(page.status_code).not_to eq(404), "Got a 404 when following Buyer order link #{order.order_number}"
    expect(page).not_to have_content("We can't find that page")
    expect(page).not_to have_content("The Market Is Currently Closed")

    # See we're not on the Delivery selection screen:
    expect(page).not_to have_content("Please choose a pick up")

    # See we're on the Order page:
    expect(page).to have_content("Order info for #{order.order_number}")
    expect(page).to have_content("Payment Method:")
    expect(page).to have_content("Delivery Status:")
  end

  #
  # Links to Orders:
  # 

  def see_admin_order_link(order:)
    link = page.first("a", text: order.order_number)
    expect(link).to be, "Didn't find any links for Order #{order.order_number}"
    expect(link[:href]).to eq(admin_order_path(order)), "Didn't see the admin-specific version of a link to Order #{order.order_number}"
  end

  def see_buyer_order_link(order:)
    link = page.first("a", text: order.order_number)
    expect(link).to be, "Didn't find any links for Order #{order.order_number}"
    expect(link[:href]).to eq(order_path(order)), "Didn't see the Buyer-specific version of a link to Order #{order.order_number}"
  end
  
  # 
  # Links to Products:
  #

  def see_admin_product_link(product:)
    link = page.first("a", text: product.name)
    expect(link).to be, "Didn't find any links for Product #{product.name}"
    expect(link[:href]).to eq(admin_product_path(product)), "Didn't see the Admin-specific version of a link to Product #{product.name}"
  end

  def see_buyer_product_link(product:)
    link = page.first("a", text: product.name)
    expect(link).to be, "Didn't find any links for Product #{product.name}"
    expect(link[:href]).to eq(product_path(product)), "Didn't see the Buyer-specific version of a link to Product #{product.name}"
  end

  # 
  # Links to Sellers:
  #

  def see_admin_seller_link(seller:)
    link = page.first("a", text: seller.name)
    expect(link).to be, "Didn't find any links for Seller #{seller.name}"
    expect(link[:href]).to eq(admin_organization_path(seller)), "Didn't see the Admin-specific version of a link to Product #{seller.name}"
  end

  def see_buyer_seller_link(seller:)
    link = page.first("a", text: seller.name)
    expect(link).to be, "Didn't find any links for Seller #{seller.name}"
    expect(link[:href]).to eq(seller_path(seller)), "Didn't see the Buyer-specific version of a link to Seller #{seller.name}"
  end


end

RSpec.configure do |config|
  config.include ReportHelpers
end
