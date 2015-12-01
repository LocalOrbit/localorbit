class AddDeletedToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :deleted_at, :datetime
  end
end
