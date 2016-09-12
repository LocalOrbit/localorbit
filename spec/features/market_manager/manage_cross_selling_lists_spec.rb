require "spec_helper"

describe "Manage cross selling lists" do
  product_management_link = "Edit cross selling product list"

  products_by_category = "Products by category"
  products_by_supplier = "Products by supplier"
  individual_products = "Individual products"

  let!(:product_01){ create(:product, :sellable) }
  let!(:product_02){ create(:product, :sellable) }
  let!(:product_03){ create(:product) }
  let!(:product_04){ create(:product) }
  let!(:product_05){ create(:product) }
  let!(:product_06){ create(:product, :sellable) }

  let!(:supplier_01){ create(:organization, :seller, products: [product_01, product_02, product_03]) }
  let!(:supplier_02){ create(:organization, :seller, products: [product_04, product_05]) }
  let!(:supplier_03){ create(:organization, :seller, products: [product_06]) }

  let!(:user) { create(:user, :market_manager) }
  let!(:user2) { create(:user, :market_manager) }

  let!(:cross_selling_disallowed_market) { create(:market, managers: [user]) }
  let!(:cross_selling_is_allowed_market) { create(:market, managers: [user], allow_cross_sell: true) }
  let!(:cross_selling_is_enabled_market) { create(:market, managers: [user], allow_cross_sell: true, self_enabled_cross_sell: true) }

  let!(:cross_selling_subscriber1) { create(
    :market,
    managers: [user],
    allow_cross_sell: true,
    self_enabled_cross_sell: true,
    organizations: [supplier_02, supplier_03]) }

  let!(:cross_selling_subscriber2) { create(
    :market,
    managers: [user],
    allow_cross_sell: true,
    self_enabled_cross_sell: true) }

  let!(:cross_selling_market) { create(
    :market,
    managers: [user],
    allow_cross_sell: true,
    self_enabled_cross_sell: true,
    cross_sells: [cross_selling_subscriber1, cross_selling_subscriber2],
    organizations: [supplier_01, supplier_02]) }

  let!(:cross_sell_list) { cross_selling_market.cross_selling_lists.create(name: "Listy McListface", status: "Published", creator: true, children_ids: [cross_selling_subscriber1]) }
  let!(:cross_sell_list2){ create(:cross_selling_list, name: "Subby McSubface", status: "Published", creator: false, parent_id: cross_sell_list.id, entity_id: cross_selling_subscriber1.id, entity_type: "Market") }

  context "when cross selling is unavailable" do
    before do
      switch_to_subdomain(cross_selling_disallowed_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_disallowed_market)
    end

    it "doesn't show the cross sell tab" do
      expect(page).to_not have_css(".tabs", text: "Cross Sell")
    end
  end 

  # TODO Test redirection to index when cross selling is available but off
  context "when cross selling is available but off" do
    before do
      switch_to_subdomain(cross_selling_is_allowed_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_is_allowed_market)
    end

    it "shows the cross sell tab" do
      expect(page).to have_css(".tabs", text: "Cross Sell")
    end

    it "lets you turn it on" do
      within ".tabs" do
        click_link "Cross Sell"
      end

      expect(page).to have_content("Cross Selling is Inactive")

      click_button "Turn on Cross Selling"

      expect(page).to have_button("Turn off Cross Selling")
    end

  end

  context "when cross selling is available and on" do
    before do
      switch_to_subdomain(cross_selling_is_enabled_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_is_enabled_market)
    end

    it "lets you turn it off" do
      within ".tabs" do
        click_link "Cross Sell"
      end

      expect(page).to have_button("Turn off Cross Selling")

      click_button "Turn off Cross Selling"

      expect(page).to have_button("Turn on Cross Selling")
    end
  end

  context "when there are no lists" do
    before do
      switch_to_subdomain(cross_selling_is_enabled_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_is_enabled_market)

      within ".tabs" do
        click_link "Cross Sell"
      end
    end

    it "lets you know you have zero" do
      expect(page).to have_content("You haven't created any Cross Selling lists yet")
    end

    it "displays a button for a new list" do
      expect(page).to have_button("Add Cross Sell List")
    end

    it "lets you create a new list" do
      click_button "Add Cross Sell List"
      expect(page).to have_content("List Name")
      expect(page).to have_content("List Status")
      expect(page).to have_button("Create List")
    end
  end

  context "when there are lists" do
    before do
      switch_to_subdomain(cross_selling_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_market)

      within ".tabs" do
        click_link "Cross Sell"
      end
    end

    it "displays the existing lists" do
      list_row = Dom::Admin::CrossSellListRow.find_by_cross_sell_list_name(cross_sell_list.name)
      expect(list_row.list_name).to eql("Listy McListface")
    end
  end

  context "when creating a new list" do
    before do
      switch_to_subdomain(cross_selling_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_market)

      within ".tabs" do
        click_link "Cross Sell"
      end
    end

    it "saves changes to a new list" do
      click_button "Add Cross Sell List"

      # RIP 'Boaty McBoatface' - democracy is DEAD.  What the hell were they thinking,
      # anyway?  Who asks for the internet's opinion about _anything_?!
      fill_in "List Name", with: "Listy McListface"
      select "Published", from: "List Status"
      select cross_selling_subscriber1.name, from: "List Visibility"

      click_button "Create List"

      expect(page).to have_content("Listy McListface")
      
      expect(page).to have_content("This Cross Selling list is Empty")
      expect(page).to have_link("Add products")
    end

  end

  context "when market is subscribing" do
    before do
      switch_to_subdomain(cross_selling_subscriber1.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_subscriber1)
    end

    it "displays available lists" do
      within ".tabs" do
        click_link "Cross Sell"
      end

      expect(page).to have_content 'My Subscriptions'

      click_link 'My Subscriptions'
      expect(page).to have_content 'Subby McSubface'
    end

    # expect product count to be y
    # expect(page).to have_content "Pending review"
    # click_link "Review Cross Sell List"
    #   expect(page).to have_content "Product_01"
    #   expect(page).to have_content "Product_03" # From Supplier_03, which doesn't sell directly to Mkt_02
    #   uncheck Product_01
    #   click_link "Close"
    #   expect product count to be y-1
    #   select "Active", from "List Status"
    #   click_link "Back to My Subscriptions"
    # expect(page).to have_content "Active"
  end

  # KXM Check dynamic product counts on product selection once AJAX is implemented
  # (selecting a supplier should change products checked and vice versa)
  context "when adding items to a list" do
    before do
      switch_to_subdomain(cross_selling_market.subdomain)
      sign_in_as user
      visit admin_market_path(cross_selling_market)

      within ".tabs" do
        click_link "Cross Sell"
      end

      click_link "Listy McListface"
    end

    it "displays the product management modal form" do
      expect(page).to have_content("Add products to cross selling list")

      click_link "Add products to cross selling list"

      expect(page).to have_content(products_by_supplier)
      expect(page).to have_content(products_by_category)
      expect(page).to have_content(individual_products)
    end

    # KXM Probably better to split all the 'adds and removes' tests...
    # Is it better to create a test cross sell list that contains products matching the criteria or re-do
    # the process of adding (duplicating the 'adds products...' process) just to remove 'em
    it "adds and removes products by supplier via form submission" do
      # Add 'em first...'
      click_link "Add products"
      click_link products_by_supplier

      expect(page).to have_content(supplier_01.name)

      supplier_row = Dom::Admin::ProductManagementSupplierRow.find_by_supplier_name(supplier_01.name)

      # KXM Unavailable products ought not show - the 'sellable' trait doesn't seem to work (the count should have been 2)... what does?
      expect(supplier_row.supplier_product_count).to eql("3")

      supplier_row.check

      click_button("Update List", match: :first)
      expect(page.all('table#cross-sell-list-products tbody tr').count).to eql(3)

      # Having been added, now remove 'em
      expect(page).to have_link(product_management_link)
      click_link product_management_link

      expect(supplier_row.checked?).to eql("checked")

      supplier_row.uncheck

      click_button("Update List", match: :first)
      # KXM remove doesn't seem to be working in the test suite, though it works on the site
      expect(page.all('table#cross-sell-list-products tbody tr').count).to eql(0)
    end

    it "adds and removes products by category via form submission" do
      # Add 'em first...'
      click_link "Add products"
      click_link products_by_category

      expect(page).to have_content(product_01.category.name)

      category_row = Dom::Admin::ProductManagementCategoryRow.find_by_category_name(product_01.category.name)

      # KXM Unavailable products ought not show - the 'sellable' trait doesn't
      # seem to work (the count should have been 2)... what does work?
      expect(category_row.category_product_count).to eql("5")

      category_row.check

      click_button("Update List", match: :first)
      expect(page.all('table#cross-sell-list-products tbody tr').count).to eql(5)

      # Having been added, now remove 'em
      expect(page).to have_link(product_management_link)
      click_link product_management_link

      expect(category_row.checked?).to eql("checked")

      category_row.uncheck

      click_button("Update List", match: :first)
      # KXM remove doesn't seem to be working in the test suite, though it works on the site
      expect(page.all('table#cross-sell-list-products tbody tr').count).to eql(0)
    end

    it "adds and removes individual products via form submission" do
      # Add 'em first...'
      click_link "Add products"
      click_link individual_products

      expect(page).to have_content(product_01.name)

      product_row = Dom::Admin::ProductManagementProductRow.find(product_01.name).first

      product_row.check

      click_button("Update List", match: :first)
      expect(page.all('table#cross-sell-list-products tbody tr').count).to eql(1)

      # Having been added, now remove 'em
      expect(page).to have_link(product_management_link)
      click_link product_management_link
      click_link individual_products

      product_row = Dom::Admin::ProductManagementProductRow.find(product_01.name).first

      expect(product_row.checked?).to eql("checked")

      product_row.uncheck

      click_button("Update List", match: :first)
      expect(page.all('table#cross-sell-list-products tbody tr').count).to eql(0)
    end
  end
end
