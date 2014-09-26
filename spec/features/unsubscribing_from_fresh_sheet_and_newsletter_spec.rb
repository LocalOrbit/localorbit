require "spec_helper"

describe "Unsubscribing" do
  context "a subscribed user" do
    include_context "fresh sheet and newsletter subscription types"
    let!(:fresh_sheet) { fresh_sheet_subscription_type }
    let!(:newsletter) { newsletter_subscription_type }

    let!(:jeff) { create(:user, name: "Jeff", subscription_types: [fresh_sheet,newsletter]) }
    let(:jeff_fresh_subscription) { jeff.subscriptions.find_by(subscription_type: fresh_sheet) }
    let(:jeff_news_subscription) { jeff.subscriptions.find_by(subscription_type: newsletter) }


    scenario "from Fresh Sheet" do
      # Visit the unsubscribe link:
      visit unsubscribe_subscriptions_path(token: jeff_fresh_subscription.token)
      expect(page).to have_content("Confirm Unsubscribe")

      # Confirm unsubscribe:
      click_on "Unsubscribe from #{fresh_sheet.name}"
      expect(page).to have_content("Unsubscribed from #{fresh_sheet.name}")

      # See the subcription is not active:
      jeff.reload
      expect(jeff.active_subscription_types).to contain_exactly(newsletter)
    end

    scenario "from Newsletter" do
      # Sanity check:
      expect(jeff.active_subscription_types).to contain_exactly(fresh_sheet,newsletter)

      # Visit the unsubscribe link:
      visit unsubscribe_subscriptions_path(token: jeff_news_subscription.token)
      expect(page).to have_content("Confirm Unsubscribe")

      # Confirm unsubscribe:
      click_on "Unsubscribe from #{newsletter.name}"
      expect(page).to have_content("Unsubscribed from #{newsletter.name}")

      # See the subcription is not active:
      jeff.reload
      expect(jeff.active_subscription_types).to contain_exactly(fresh_sheet)
    end

    scenario "from an already-unsubscribed Fresh Sheet" do
      # unsubscribe:
      jeff.unsubscribe_from(fresh_sheet)
      expect(jeff.active_subscription_types).to contain_exactly(newsletter)

      # Visit the unsubscribe link:
      visit unsubscribe_subscriptions_path(token: jeff_fresh_subscription.token)
      
      click_on "Unsubscribe from #{fresh_sheet.name}"
      expect(page).to have_content("Unsubscribed from #{fresh_sheet.name}")

      # See the subcription remains inactive:
      jeff.reload
      expect(jeff.active_subscription_types).to contain_exactly(newsletter)
    end

    scenario "with a bad token" do
      visit unsubscribe_subscriptions_path(token: "whateveR")
      expect(page).to have_content("Unsubscribed from Emails")
    end

    scenario "with no token" do
      visit unsubscribe_subscriptions_path
      expect(page).to have_content("Unsubscribed from Emails")
    end


  end
end
