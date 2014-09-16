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

    # See we're not on the Delivery selection screen:
    expect(page).not_to have_content("Please choose a pick up")

    # See we're on the Order page:
    expect(page).to have_content("Order info for #{order.order_number}")
    expect(page).to have_content("Payment Method:")
    expect(page).to have_content("Delivery Status:")
  end

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

end

RSpec.configure do |config|
  config.include ReportHelpers
end
