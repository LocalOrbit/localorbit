require 'spec_helper'

feature 'Record payments to suppliers', :js  do

  include_context 'the mini market'

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in_as mary
    SetOrderItemsStatus.perform(
      user: mary,
      order_item_ids: [order1_item1.id, order2_item1.id],
      delivery_status: 'delivered'
    )
  end

  it 'displays all sellers to whom a managed market owes payment' do
    visit admin_financials_vendor_payments_path

    expect(page).to have_content('Record Payments to Suppliers')
    expect(page).to have_content("Sally's Staples")
    expect(page).to have_content('2 orders from Mini Market')
    expect(page).to have_content('$13.98')
  end

end
