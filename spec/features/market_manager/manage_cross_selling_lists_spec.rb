require "spec_helper"

#   context "for a market with no cross sell lists" do
#     it "shows new list button" do
#     end
#   end

#   context "for a market with cross selling lists" do
#     it "shows a list of cross selling lists" do
#     end
#     it "saves changes to cross selling markets" do
#     end
#   end

#   context "view organization cross sells" do
#     it "allows organization to see their cross sells" do
#     end
#   end

describe "Manage cross selling lists" do
  # Set up:
  #   Two Markets that cross sell with each other
  #   Supplier Organizations, some associated with Mkt_01, some with Mkt_02, some with both
  #   Organizations have associated products
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  context "when cross selling is unavailable" do
    # - Status check? Lack of 'Cross Sell' tab
  end 

  # - (Mkt_01)
  context "when cross selling is available but off" do
    it "lets you turn it on" do
      expect(page).to have_content("Turn on Cross Selling")

      click_button "Turn on Cross Selling"

      # expect market to now be able to cross sell
    end

  end

  context "when cross selling is available and on" do
    it "lets you turn it off" do
      expect(page).to have_content("Turn off Cross Selling")
    end
  end

  # - No lists
  context "when there are no lists" do
    it "lets you know you have zero" do
      expect(page).to have_content("You haven't created a Cross Selling list yet")
    end

    it "displays a button for a new list" do
      expect(page).to have_content("Add Cross Sell List")
    end
  end

  context "when creating a new list" do
    it "saves changes to a new list" do
      click_button "Add Cross Sell List"

      expect(page).to have_content("Your Cross Selling list is Empty")

      fill_in "List Name", with: "Listy McListface" # RIP 'Boaty McBoatface' - democracy is DEAD.  What the hell were they thinking, anyway?  Who asks for the internet's opinion about _anything_?!
      select "Subscribing market", from: "List Visibility"

      click_button "Create List"

      # - Check for the newly created list on the resulting index page.  It'll look something like this:
      # lists = Dom::Admin::[list item Dom name].first
      # expect(lists.list_name.value).to eql("Listy McListface")
    end
  end

  #     Product list
  #       expect content Suppliers
  #       expect content Categories
  #       expect content Products

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

  # For market with cross selling and on and subscribing
  #   expect content 'Subscriptions (1)'
  #   click 'Subscriptions (1)'
  #   expect content 'List_01'
  #   expect product count to be y
  #   expect content 'Pending review'
  #   click 'Review Cross Sell List'
  #     expect content 'Product_01'
  #     expect content 'Product_03' # From Supplier_03, which doesn't sell directly to Mkt_02
  #     uncheck Product_01
  #     click 'Close'
  #     expect product count to be y-1
  #     select 'Active' from 'List Status'
  #     click 'Back to My Subscriptions'
  #   expect content 'Active'

end
