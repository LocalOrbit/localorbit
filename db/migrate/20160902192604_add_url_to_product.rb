class AddUrlToProduct < ActiveRecord::Migration
  def change
    add_column :products, :aws_image_url, :string
  end
end
