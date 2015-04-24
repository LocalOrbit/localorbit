class AddPaymentProviderId < ActiveRecord::Migration
  def change
    change_table :markets do |t|
      t.string :payment_provider
    end

    change_table :payments do |t|
      t.string :payment_provider
    end

    change_table :orders do |t|
      t.string :payment_provider
    end
  end
end
