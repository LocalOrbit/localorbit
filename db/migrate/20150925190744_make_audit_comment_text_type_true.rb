class MakeAuditCommentTextTypeTrue < ActiveRecord::Migration
  def change
  	change_column :delivery_schedules, :toggle_on, :boolean, :default => true
  end
end
