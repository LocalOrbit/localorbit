class AddStripeIdToPlans < ActiveRecord::Migration
	class Plans < ActiveRecord::Base
	end

  def up
    add_column :plans, :stripe_id, :string
    Plans.reset_column_information

    execute <<-SQL
    	UPDATE plans SET stripe_id = trim(both from split_part(upper(name), ' ', 1))
    SQL
  end

  def down
  	remove_column :plans, :stripe_id
  end
end
