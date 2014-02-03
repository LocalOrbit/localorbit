class AddInvitationCountToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer    :invitations_count, default: 0
      t.index      :invitations_count
    end
  end
end
