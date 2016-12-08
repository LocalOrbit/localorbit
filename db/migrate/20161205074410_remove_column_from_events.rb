class RemoveColumnFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :timestamps, :boolean
  end
end
