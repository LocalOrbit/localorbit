class AddUniqueConstraintToCrossSellingListProducts < ActiveRecord::Migration
  def up
    execute <<-SQL
      alter table cross_selling_list_products
        add constraint cross_selling_list_product_unique_list_products_ids unique (cross_selling_list_id, product_id);
    SQL
  end

  def down
    execute <<-SQL
      alter table cross_selling_list_products
        drop constraint if exists cross_selling_list_product_unique_list_products_ids;
    SQL
  end
end
