class AddLivemodeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :livemode, :boolean, default: true
  end
end
