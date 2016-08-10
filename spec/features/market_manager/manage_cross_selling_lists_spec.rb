require "spec_helper"

describe "Manage cross selling lists" do
  let!(:user) { create(:user, :market_manager) }
  let!(:user2) { create(:user, :market_manager) }

  let!(:cross_selling_disallowed_market) { create(:market, managers: [user]) }
  let!(:cross_selling_is_allowed_market) { create(:market, managers: [user], allow_cross_sell: true) }
  let!(:cross_selling_is_enabled_market) { create(:market, managers: [user], allow_cross_sell: true, self_enabled_cross_sell: true) }

  let!(:cross_selling_subscriber1) { create(:market, managers: [user], allow_cross_sell: true, self_enabled_cross_sell: true) }
  let!(:cross_selling_subscriber2) { create(:market, managers: [user], allow_cross_sell: true, self_enabled_cross_sell: true) }

  let!(:cross_selling_market) { create(:market, managers: [user], allow_cross_sell: true, self_enabled_cross_sell: true, cross_sells: [cross_selling_subscriber1, cross_selling_subscriber2]) }
  let!(:cross_sell_list) { cross_selling_market.cross_selling_lists.create(name: "Listy McListface", status: "Published", children_ids: [cross_selling_subscriber1]) }
  let!(:cross_sell_list2){ create(:cross_selling_list, name: "Subby McSubface", status: "Published", creator: false, parent_id: cross_sell_list.id, entity_id: cross_selling_subscriber1.id, entity_type: "Market")}

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

      # KXM The design specifies this as a link, but a button is easier for now
      # expect(page).to have_content("Turn off Cross Selling")
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

      # KXM The design specifies this as a link, but a button is easier for now
      # expect(page).to have_content("Turn off Cross Selling")
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

      expect(page).to have_content 'Subscriptions (1)'

      click_link 'Subscriptions (1)'
      expect(page).to have_content 'Subby McSubface'
    end

    # expect product count to be y
    # expect content 'Pending review'
    # click 'Review Cross Sell List'
    #   expect content 'Product_01'
    #   expect content 'Product_03' # From Supplier_03, which doesn't sell directly to Mkt_02
    #   uncheck Product_01
    #   click 'Close'
    #   expect product count to be y-1
    #   select 'Active' from 'List Status'
    #   click 'Back to My Subscriptions'
    # expect content 'Active'
  end

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
      click_link "Add products"

      expect(page).to have_content("Add Products to Cross Selling List")
      expect(page).to have_content("Suppliers")
      expect(page).to have_content("Categories")
      expect(page).to have_content("Products")
    end
  end

  # it "adds products by supplier" do
  #       # test adding products by supplier (across categories)
  #       add Supplier_01
  #       expect product count of Supplier_01 to be y/y
  #       expect product count of Supplier_02 to be 0/y
  #       click 'Categories'
  #       expect product count of Category_01 to be x/y # Supplier_01 has some but not all
  #       expect product count of Category_02 to be y/y # Supplier_01 has all
  #       expect product count of Category_03 to be 0/y # Supplier_01 has none

  #       # test adding products by category (across suppliers)
  #       add Category_01
  #       expect product count of Category_01 to be y/y
  #       click 'Suppliers'
  #       expect product count of Supplier_01 to be y/y
  #       expect product count of Supplier_02 to be w/y # Supplier_02 has some of Category_01

  #       # test adding and removing products by product (across suppliers and categories)
  #       click 'Products'
  #       expect Product_01 to be checked
  #       expect Product_02 to be checked
  #       expect Product_03 to be unchecked
  #       add Product_03
  #       click 'Categories'
  #       expect product count of Category_03 to be 1/y # From adding Product_03
  #       click 'Suppliers'
  #       expect prduct count of Supplier_03 to be 1/y # From adding Product_03

  #       click 'Add to List' # Perhaps 'Save List' to better indicate you're done?
  #       expect product count of List to be y/y

  #       select 'active' from 'List Status'
  #       click 'update'

  #       click 'Back to my Lists'
  #   Lists
  #     expect content 'List_01'
  #     expect content 'active'

end
