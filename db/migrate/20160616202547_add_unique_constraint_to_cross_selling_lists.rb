class AddUniqueConstraintToCrossSellingLists < ActiveRecord::Migration
  def up
    execute <<-SQL
      alter table cross_selling_lists
        add constraint cross_selling_lists_unique_parent_entity_ids unique (parent_id, entity_id);
    SQL
  end

  def down
    execute <<-SQL
      alter table cross_selling_lists
        drop constraint if exists cross_selling_lists_unique_parent_entity_ids;
    SQL
  end
end
