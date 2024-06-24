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
puts 'creating admin organization...'
admin_org = Organization.find_or_initialize_by(name: 'Admin Org', org_type: Organization::TYPE_ADMIN)
admin_org.allow_purchase_orders = true
admin_org.can_sell = false
admin_org.active = true
admin_org.needs_activated_notification = false
admin_org.save!

puts 'creating admin user... (email : admin@example.com)'
admin_user = User.find_or_create_by!(email: "admin@example.com") {|user|
  user.password = "password1"
  user.password_confirmation = "password1"
  user.role = "admin"
  user.confirmed_at = Time.current
}

puts 'associating admin user to organization...'
unless admin_org.users.include?(admin_user)
  admin_org.users << admin_user
  admin_org.save!
end

puts 'creating Springfield market'
Market.where(subdomain:"springfield").exists? || Market.create(
  name:"Springfield Market",
  subdomain:"springfield"
)

puts 'importing taxonomy...'
ImportLegacyTaxonomy.run(File.expand_path('../taxonomy.csv', __FILE__))
puts 'importing role actions...'
ImportRoleActions.run(File.expand_path('../role_actions.csv', __FILE__))

puts 'creating base units...'
Unit.find_or_create_by!(singular: 'Pound', plural: 'Pounds')
Unit.find_or_create_by!(singular: 'Bushel', plural: 'Bushels')
Unit.find_or_create_by!(singular: 'Crate', plural: 'Crates')
Unit.find_or_create_by!(singular: 'Bunch', plural: 'Bunches')
Unit.find_or_create_by!(singular: 'Box', plural: 'Boxes')

puts 'creating base plans...'
Plan.create(name: "Start Up")
Plan.create(name: "Grow",     cross_selling: true, discount_codes: true, custom_branding: true)
Plan.create(name: "Accelerate", cross_selling: true, discount_codes: true, custom_branding: true, advanced_pricing: true,
  advanced_inventory: true, promotions: true, order_printables: true, packing_labels: true, sellers_edit_orders: true)

puts '...and done seeding!'
