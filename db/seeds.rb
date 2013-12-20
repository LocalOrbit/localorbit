# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#


lo_market = Market.where(subdomain:"springfield").first || Market.create(
  name:"Springfield Market",
  subdomain:"springfield"
)

erika = User.create!(
  email: "erika@localorb.it",
  password: "KKBz2yVKg2F",
  password_confirmation: "KKBz2yVKg2F",
  role: "admin",
  name: "Erika Block"
)

anna = User.create!(
  email: "anna@localorb.it",
  password: "Cau7t3vwW",
  password_confirmation: "Cau7t3vwW",
  role: "admin",
  name: "Anna Richardson"
)

ragan = User.create!(
  email: "ragan@localorb.it",
  password: "T8gKxCCc6k",
  password_confirmation: "T8gKxCCc6k",
  role: "admin",
  name: "Ragan Erickson"
)

kate = User.create!(
  email: "kate@localorb.it",
  password: "FH6sLbw2r",
  password_confirmation: "FH6sLbw2r",
  role: "admin",
  name: "Kate Barker"
)


[erika, anna, ragan, kate].each do |u|
  u.managed_markets << lo_market
  u.save!
end
