require "spec_helper"

feature "modifying order credits", :js do
  let!(:admin) { create(:user, :admin) }
  let!(:market_manager) { create :user, managed_markets: [market] }
  let(:user) {create(:user)}
  let!(:seller) { create(:organization, :single_location, :seller, users: [user]) }
  let(:market) { create(:market, organizations: [seller]) }
  let!(:order) { create(:order, :with_items, market: market) }

  def visit_order_page
    visit admin_order_path order.id
  end

  before do
    product = order.items.first.product
    product.organization = seller
    product.save
  end

  context "as a permitted user" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as admin
    end

    describe "observing previously set credits" do
      before do
        @credit = create(:credit, order: order)
        visit_order_page
      end

      it "displays the credited amount" do
        expect(page).to have_text "Credit: $1.50"
        @credit.update_attributes(amount_type: Credit::PERCENTAGE, amount: 50)
        visit_order_page
        expect(page).to have_text "Credit: $3.50"
        #expect(page).to have_text @credit.notes
      end
    end

    describe "creating a credit" do
      before do
        visit_order_page
        find(".app-edit-credit-modal-button").click
        expect(page).to have_selector(".app-edit-credit-modal", visible: true)
      end

      xit "works for fixed credits", :shaky do
        select "Fixed", from: "amount-type"
        fill_in "amount", with: "2.25"
        fill_in "notes", with: "New notes."
        click_button "Save"

        using_wait_time(20) do
          expect(page).to have_selector(".app-edit-credit-modal", visible: false)
          expect(page).to have_text "Credit: $2.25"
          expect(page).to have_text "New notes."
        end

        patiently(10) do
          credit = order.reload.credit
          expect(credit.amount_type).to eql "fixed"
          expect(credit.amount).to eql 2.25
        end
      end
    end

    describe "updating a credit" do
      before do
        create(:credit, order: order, amount: 0.01)
        visit_order_page
        expect(page).to have_text "Credit: $0.01"
        find(".app-edit-credit-modal-button").click
        expect(page).to have_selector(".app-edit-credit-modal", visible: true)
      end

      xit "works for fixed credits", :shaky do
        select "Fixed", from: "amount-type"
        fill_in "amount", with: "2.25"
        fill_in "notes", with: "New notes."
        click_button "Save"

        using_wait_time(20) do
          expect(page).to have_selector(".app-edit-credit-modal", visible: false)
          expect(page).to have_text "Credit: $2.25"
          expect(page).to have_text "New notes."
        end

        patiently(10) do
          credit = order.reload.credit
          expect(credit.amount_type).to eql "fixed"
          expect(credit.amount).to eql 2.25
        end
      end
    end
  end

  context "as a pleb" do
    it "does not show the modify credit button" do
      switch_to_subdomain(market.subdomain)
      sign_in_as user
      visit_order_page
      expect(page).to_not have_selector(".app-edit-credit-modal-button")
    end
  end
end
