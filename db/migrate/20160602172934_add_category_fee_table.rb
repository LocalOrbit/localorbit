class AddCategoryFeeTable < ActiveRecord::Migration
  def change
    create_table :category_fees do |t|
        t.integer :category_id
        t.integer :market_id
        t.decimal :fee_pct, precision: 5, scale: 3

        t.timestamps
    end
  end

  def data
    RoleAction.create("description"=>"Market_Category_Fees:Index", "org_types"=>["A", "M"], "section"=>"market_category_fees", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
  end
end
