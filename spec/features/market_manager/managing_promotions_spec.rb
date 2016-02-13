require "spec_helper"

describe "Managing featured promotions" do
  let!(:market)  { create(:market) }
  let!(:seller)  { create(:organization, :seller, markets: [market]) }
  let!(:product) { create(:product, :sellable, organization: seller) }

  let!(:active_promotion) { create(:promotion, :active, market: market, product: product, name: "Active Promotion", created_at: Time.parse("2011-05-26")) }
  let!(:promotion) { create(:promotion, market: market, product: product, name: "Unactive Promotion", created_at: Time.parse("2014-05-26")) }

  context "as a market manager" do
    let(:user) { create(:user, :market_manager, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user

      visit admin_promotions_path
    end

    context "list view" do
      it "shows a list of the featured promotions for the market" do
        expect(page).to have_content("Featured Promotions")

        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(2)
        expect(promotions.map(&:name)).to include(active_promotion.name, promotion.name)
      end
    end

    context "multi market membership" do
      let!(:second_market) { create(:market) }
      let!(:user) { create(:user, :market_manager, managed_markets: [market, second_market]) }

      before do
        visit admin_promotions_path
      end

      context "create a promotion" do
        it "accepts valid input" do
          click_link "Add New Promotion"

          fill_in "Name", with: "Summer Promotion"
          select market.name, from: "Market"
          fill_in "Title", with: "Summer Promotion: Apples"
          select product.name, from: "Product"

          click_button "Save Promotion"

          expect(page).to have_content("Successfully created the featured promotion.")

          promotions = Dom::Admin::FeaturedPromotionRow.all
          expect(promotions.count).to eql(3)
          expect(promotions.map(&:name)).to include(active_promotion.name, promotion.name, "Summer Promotion")
        end

        it "displays errors for invalid input" do
          click_link "Add New Promotion"

          fill_in "Name", with: ""
          select market.name, from: "Market"
          fill_in "Title", with: "Summer Promotion: Apples"
          select product.name, from: "Product"

          click_button "Save Promotion"

          expect(page).to_not have_content("Successfully created the featured promotion.")
          expect(page).to have_content("Name can't be blank")
        end
      end

      context "update a promotion" do
        it "accepts valid input" do
          click_link active_promotion.name

          fill_in "Name", with: "Changed Promotion"

          click_button "Save Promotion"

          expect(page).to have_content("Successfully updated the featured promotion.")

          promotions = Dom::Admin::FeaturedPromotionRow.all
          expect(promotions.count).to eql(2)
          expect(promotions.map(&:name)).to include("Changed Promotion")
        end

        it "displays errors for invalid input" do
          click_link active_promotion.name

          fill_in "Name", with: ""

          click_button "Save Promotion"

          expect(page).to_not have_content("Successfully updated the featured promotion.")
          expect(page).to have_content("Name can't be blank")
        end
      end
    end

    context "single market membership" do
      context "create a promotion" do
        it "accepts valid input" do
          click_link "Add New Promotion"

          fill_in "Name", with: "Summer Promotion"
          fill_in "Title", with: "Summer Promotion: Apples"
          select product.name, from: "Product"

          click_button "Save Promotion"

          expect(page).to have_content("Successfully created the featured promotion.")

          promotions = Dom::Admin::FeaturedPromotionRow.all
          expect(promotions.count).to eql(3)
          expect(promotions.map(&:name)).to include(active_promotion.name, promotion.name, "Summer Promotion")
        end

        it "displays errors for invalid input" do
          click_link "Add New Promotion"

          fill_in "Name", with: ""
          fill_in "Title", with: "Summer Promotion: Apples"
          select product.name, from: "Product"

          click_button "Save Promotion"

          expect(page).to_not have_content("Successfully created the featured promotion.")
          expect(page).to have_content("Name can't be blank")
        end
      end

      context "update a promotion" do
        it "accepts valid input" do
          click_link active_promotion.name

          fill_in "Name", with: "Changed Promotion"

          click_button "Save Promotion"

          expect(page).to have_content("Successfully updated the featured promotion.")

          promotions = Dom::Admin::FeaturedPromotionRow.all
          expect(promotions.count).to eql(2)
          expect(promotions.map(&:name)).to include("Changed Promotion")
        end

        it "displays errors for invalid input" do
          click_link active_promotion.name

          fill_in "Name", with: ""

          click_button "Save Promotion"

          expect(page).to_not have_content("Successfully updated the featured promotion.")
          expect(page).to have_content("Name can't be blank")
        end
      end
    end

    context "remove a promotion" do
      it "is successful" do
        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(2)

        Dom::Admin::FeaturedPromotionRow.find_by_name(promotion.name).click_delete

        promotions = Dom::Admin::FeaturedPromotionRow.all
        expect(promotions.count).to eql(1)
        expect(promotions.map(&:name)).to include(active_promotion.name)
      end
    end

    context "activate a promotion" do
      it "activate an inactive promotion" do
        Dom::Admin::FeaturedPromotionRow.find_by_name(promotion.name).click_activate

        row = Dom::Admin::FeaturedPromotionRow.find_by_name(promotion.name)
        expect(row.links).to have_content("Deactivate")

        row = Dom::Admin::FeaturedPromotionRow.find_by_name(active_promotion.name)
        expect(row.links).to have_content("Activate")
      end
    end

    context "deactivate a promotion" do
      it "deactivate an active promotion" do
        Dom::Admin::FeaturedPromotionRow.find_by_name(active_promotion.name).click_deactivate

        row = Dom::Admin::FeaturedPromotionRow.find_by_name(active_promotion.name)
        expect(row.links).to have_content("Activate")

        row = Dom::Admin::FeaturedPromotionRow.find_by_name(promotion.name)
        expect(row.links).to have_content("Activate")
      end
    end
  end

  context "filtering", :js do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as user

      visit admin_promotions_path
    end

    context "one market" do
      it "does not have a market filter box" do
        expect(page).to_not have_field("Market")
      end
    end

    context "multiple markets" do
      let!(:second_market) { create(:market, managers: [user]) }
      let!(:second_market_promotion) { create(:promotion, market: second_market) }

      it "filters by market" do
        visit admin_promotions_path

        select second_market.name, from: "q_market_id_in", visible: false
        sleep(1)

        expect(Dom::Admin::FeaturedPromotionRow.all.count).to eql(1)
        expect(Dom::Admin::FeaturedPromotionRow.find_by_name(second_market_promotion.name)).to_not be_nil
        #unselect second_market.name, from: "q_market_id_in", visible: false

      end
    end
  end
end
