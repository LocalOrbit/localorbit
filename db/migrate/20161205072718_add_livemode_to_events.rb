class AddLivemodeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :livemode, :boolean, default: false
  end
end
