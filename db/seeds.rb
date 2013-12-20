# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#


Market.where(subdomain:"springfield").first || Market.create(
  name:"Springfield Market",
  subdomain:"springfield"
)

User.create!(
  email: "erika@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Erika Block"
)

User.create!(
  email: "anna@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Anna Richardson"
)

User.create!(
  email: "ragan@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Ragan Erickson"
)

User.create!(
  email: "kate@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Kate Barker"
)
