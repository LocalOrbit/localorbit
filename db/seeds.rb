# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#


Market.where(subdomain:"springfield").exists? || Market.create(
  name:"Springfield Market",
  subdomain:"springfield"
)

User.where(email: "erika@localorb.it").exists? || User.create!(
  email: "erika@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Erika Block"
)

User.where(email: "anna@localorb.it").exists? || User.create!(
  email: "anna@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Anna Richardson"
)

User.where(email: "ragan@localorb.it").exists? || User.create!(
  email: "ragan@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Ragan Erickson"
)

User.where(email: "kate@localorb.it").exists? || User.create!(
  email: "kate@localorb.it",
  password: "password1",
  password_confirmation: "password1",
  role: "admin",
  name: "Kate Barker"
)

ImportLegacyTaxonomy.run(File.expand_path('../taxonomy.csv', __FILE__))


Unit.find_or_create_by!(singular: 'Pound', plural: 'Pounds')
Unit.find_or_create_by!(singular: 'Bushel', plural: 'Bushels')
Unit.find_or_create_by!(singular: 'Crate', plural: 'Crates')
Unit.find_or_create_by!(singular: 'Bunch', plural: 'Bunches')
Unit.find_or_create_by!(singular: 'Box', plural: 'Boxes')

