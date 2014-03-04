module Admin
  class DeliverySchedulesController < AdminController
    before_action :require_admin_or_market_manager
    before_action do
      @market = Market.where(id: params[:market_id]).first
    end

    def index
    end

    def new
      @delivery_schedule = @market.delivery_schedules.build
    end

    def create
      @delivery_schedule = @market.delivery_schedules.build(delivery_schedule_params)
      if @delivery_schedule.save
        redirect_to [:admin, @market, :delivery_schedules], notice: 'Saved delivery schedule.'
      else
        render :new
      end
    end

    private

    def delivery_schedule_params
      params.require(:delivery_schedule).permit(
        :day,
        :fee,
        :fee_type,
        :order_cutoff,
        :require_delivery,
        :require_cross_sell_delivery,
        :seller_fulfillment_location_id,
        :seller_delivery_start,
        :seller_delivery_end,
        :buyer_pickup_location_id,
        :buyer_pickup_start,
        :buyer_pickup_end,
        :market_pickup
      )
    end
  end
end
