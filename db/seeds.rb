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
admin_org = Organization.find_or_create_by!(name: "Admin Org", allow_purchase_orders: true) {|org|
  org.can_sell = false
}
admin_org.active = true
admin_org.org_type = "A"
admin_org.needs_activated_notification = false
admin_org.save!

admin_user = User.find_or_create_by!(email: "admin@example.com") {|user|
  user.password = "password1"
  user.password_confirmation = "password1"
  user.role = "admin"
  user.confirmed_at = Time.current
}

unless admin_org.users.include?(admin_user)
  admin_org.users << admin_user
  admin_org.save!
end

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
