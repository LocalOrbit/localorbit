class AddNeedsActivatedNotificationOnOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :needs_activated_notification, :bool, default: true
  end
end
