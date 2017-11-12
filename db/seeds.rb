# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#

# Admin
User.find_or_create_by!(email: 'admin@example.com') { |user|
  user.password = "password1"
  user.password_confirmation = "password1"
  user.role = "admin"
  user.confirmed_at = Time.current
}

Market.where(subdomain:"springfield").exists? || Market.create(
  name:"Springfield Market",
  subdomain:"springfield"
)

ImportLegacyTaxonomy.run(File.expand_path('../taxonomy.csv', __FILE__))
ImportRoleActions.run(File.expand_path('../role_actions.csv', __FILE__))

Unit.find_or_create_by!(singular: 'Pound', plural: 'Pounds')
Unit.find_or_create_by!(singular: 'Bushel', plural: 'Bushels')
Unit.find_or_create_by!(singular: 'Crate', plural: 'Crates')
Unit.find_or_create_by!(singular: 'Bunch', plural: 'Bunches')
Unit.find_or_create_by!(singular: 'Box', plural: 'Boxes')

Plan.create(name: "Start Up")
Plan.create(name: "Grow",     cross_selling: true, discount_codes: true, custom_branding: true)
Plan.create(name: "Automate", cross_selling: true, discount_codes: true, custom_branding: true, automatic_payments: true)
