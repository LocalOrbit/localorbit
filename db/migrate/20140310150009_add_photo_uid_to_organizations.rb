class AddPhotoUidToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :photo_uid, :string
  end
end
