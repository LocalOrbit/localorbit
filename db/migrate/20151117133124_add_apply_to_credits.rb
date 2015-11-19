class AddApplyToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :apply_to, :string
  end
end
