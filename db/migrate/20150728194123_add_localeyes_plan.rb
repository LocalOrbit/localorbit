class AddLocaleyesPlan < ActiveRecord::Migration
  def up
    Plan.create(name: "LocalEyes", cross_selling: true, discount_codes: true, custom_branding: true, order_printables: true, has_procurement_managers: true, packing_labels: true)
  end

  def down
    local_eyes_plan = Plan.find_by_name("LocalEyes")
    local_eyes_plan.destroy unless local_eyes_plan.nil?
  end
end
