class AddPhoneToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :phone, :string
    add_column :locations, :fax, :string
  end
end
