puts "development got loaded..."
# Market
market = Market.find_or_create_by!(name: "Fulton St. Farmer's Maket") {|m|
  m.timezone = "EST"
  m.contact_name =  'Jill Smith'
  m.contact_email = 'jill@smith.com'
  m.contact_phone = '616-222-2222'
}

market_manager = User.find_or_create_by!(email: "mm@example.com") {|mm|
  mm.password = "password1"
  mm.password_confirmation = "password1"
  mm.role = "user"
}

unless market_manager.managed_markets.include?(market_manager)
  market_manager.managed_markets << market
end


# Buyer
buy_org = Organization.find_or_create_by!(name: "Farm to Table Cafe") {|org|
  org.can_sell = false
}

buy_loc = Location.find_or_create_by!(name: "Downtown Location") {|loc| 
  loc.address = "1234 Perl St."
  loc.city = "Grand Rapids"
  loc.state = "Michigan"
  loc.organization_id = buy_org.id
  loc.zip = "49546"
}

buyer_user = User.find_or_create_by!(email: "buyer@example.com") {|user|
  user.password = "password1"
  user.password_confirmation = "password1"
  user.role = "user"
}

unless buy_org.users.include?(buyer_user)
  buy_org.users << buyer_user
  buy_org.save!
end

# Seller
sell_org = Organization.find_or_create_by!(name: "Alto Valley Farms") {|org|
  org.can_sell = true
}

sell_loc = Location.find_or_create_by!(name: "Default Location") {|loc| 
  loc.address = "32 Boynton Rd."
  loc.city = "Alto"
  loc.state = "Michigan"
  loc.zip = "48846"
  loc.organization_id = sell_org.id
}

product = Product.find_or_create_by!(name: "Grapes") {|prod|
  prod.name = "Grapes"
  prod.category_id = Category.last.id
  prod.organization_id = sell_org.id
}

seller_user = User.find_or_create_by!(email: "seller@example.com"){ |user|
  user.password = "password1"
  user.password_confirmation = "password1"
  user.role = "user"
}

unless sell_org.users.include?(seller_user)
  sell_org.users << seller_user
  sell_org.save!
end

market_manager.save!

market.organizations << buy_org unless market.organizations.include?(buy_org)
market.organizations << sell_org unless market.organizations.include?(sell_org)

market_address = MarketAddress.find_or_create_by!(name: "Default Marketplace") {|addr|
  addr.address = "89 Niles Rd."
  addr.city = "Rockford"
  addr.state = "Michigan"
  addr.zip = "48836"
  addr.market_id = market.id
}
