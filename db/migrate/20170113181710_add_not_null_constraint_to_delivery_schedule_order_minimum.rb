class AddNotNullConstraintToDeliveryScheduleOrderMinimum < ActiveRecord::Migration
  def change
    change_column_null(:delivery_schedules, :order_minimum, false, 0.0 )
    # Arg #3 answers the question 'Allow null values?'
    # Arg #4 defines a value to replace any existing null values
  end
end
