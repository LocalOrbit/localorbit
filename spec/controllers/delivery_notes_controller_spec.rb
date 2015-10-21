require 'spec_helper'

describe DeliveryNotesController do
	let!(:market)   { create(:market, :with_address, :with_delivery_schedule) }
  let!(:delivery) { market.delivery_schedules.first.next_delivery }
  let!(:seller)   { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product)  { create(:product, :sellable, organization: seller) }

  let!(:buyer)    { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:user)     { create(:user, organizations: [buyer]) }

  let!(:cart)     { create(:cart, market: market, organization: buyer, delivery: delivery, location: buyer.locations.first, user: user) }

  before do
    sign_in(user)
    switch_to_subdomain(market.subdomain)
  end

  it "allows user to add note" do
  	# buyer user fills in cart (?)
  	# buyer user can click on link for note on cart page
  	# buyer user sees "add note" text or whatever on note page and clicks save
  	# there is a new record in the database with the new temp note text (and the right ids)
  end

  it "allows user to edit note" do
  	# buyer user clicks on note for same supplier as above
  	# buyer user sees that text on screen in the box or w/e
  end

  it "saves only one note per supplier" do
  	# open note and go to edit, not new, 
  	# find only one note for supplier
  end

  it "shows up to supplier in order" do
  	# buyer user: make note for other supplier??
  	# buyer user: place order
  	# sign out of current user, sign into user who is ONE supplier on the order
  	# supplier user go to orders path and most recent order (/go view that order)
  	# supplier user see one note
  	# supplier user do NOT see more than one note
  end

	
end