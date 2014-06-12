class CreatePlans < ActiveRecord::Migration
  class Plan < ActiveRecord::Base; end

  def up
    create_table :plans do |t|
      t.string :name
      t.boolean :discount_codes, default: false
      t.boolean :cross_selling, default: false
      t.boolean :custom_branding, default: false
      t.boolean :automatic_payments, default: false

      t.timestamps
    end

    Plan.create(name: "Start Up")
    Plan.create(name: "Grow",     cross_selling: true, discount_codes: true, custom_branding: true)
    Plan.create(name: "Automate", cross_selling: true, discount_codes: true, custom_branding: true, automatic_payments: true)
  end

  def down
    drop_table :plans
  end
end
