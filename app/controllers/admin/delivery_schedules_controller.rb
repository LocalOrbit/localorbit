module Admin
  class DeliverySchedulesController < AdminController
    before_action :require_admin_or_market_manager
    before_action do
      @market = current_user.markets.find(params[:market_id])
    end

    def index
      @delivery_schedules = @market.delivery_schedules.order(:day)
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

    def edit
      @delivery_schedule = @market.delivery_schedules.find(params[:id])
      render :new
    end

    def update
      @delivery_schedule = @market.delivery_schedules.find(params[:id])
      if @delivery_schedule.update_attributes(delivery_schedule_params)
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
