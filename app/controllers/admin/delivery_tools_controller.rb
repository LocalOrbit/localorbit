class Admin::DeliveryToolsController < AdminController
  before_action :require_selected_market

  def show
    @upcoming_deliveries = current_user.markets.map{|market| market.upcoming_deliveries_for_user(current_user).decorate}.flatten
    # TODO: need pick lists separated out for the supplier upcoming deliveries view
# should return a set (an iterable) of hashes of seller delivery start time and seller fulfilmment location (dropoff loc) for each on the market
 # method name on mkt: delivery_schedule_sets_for_pick_lists

  	
  	# binding.pry
    @pick_list_delivery_schedules = current_user.markets.map{|market| market.delivery_schedule_sets_for_pick_lists}.flatten.map{|dsfp| DeliverySchedule.where(seller_delivery_start:dsfp[:time],seller_fulfillment_location_id:dsfp[:loc])}.flatten
  
    # for each of those delivery schedules
    # want the ITEMS that go with all future deliveries

# these things happen in the show delivery_tools:
# delivery.delivery_schedule.market.name
# delivery.upcoming_delivery_date_heading (this is the whole point)


  end
end
