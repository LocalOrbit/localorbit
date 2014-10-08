module Admin
  class DeliverySchedulesController < AdminController
    before_action :require_admin_or_market_manager
    before_action :find_market

    def index
      @delivery_schedules = @market.delivery_schedules.visible.order(:day)
    end

    def new
      @delivery_schedule = @market.delivery_schedules.build
    end

    def create
      @delivery_schedule = @market.delivery_schedules.build(delivery_schedule_params)
      if @delivery_schedule.save
        AddDeliveryScheduleToProducts.perform(delivery_schedule: @delivery_schedule, market: @market)

        redirect_to [:admin, @market, :delivery_schedules], notice: "Saved delivery schedule."
      else
        render :new
      end
    end

    def edit
      @delivery_schedule = @market.delivery_schedules.visible.find(params[:id])
      render :new
    end

    def update
      delivery_schedule = @market.delivery_schedules.visible.find(params[:id])

      interactor = UpdateDeliveryScheduleAndCurrentDelivery.perform(
        params: delivery_schedule_params,
        delivery_schedule: delivery_schedule
      )

      if interactor.success?
        redirect_to [:admin, @market, :delivery_schedules], notice: "Saved delivery schedule."
      else
        @delivery_schedule = interactor.delivery_schedule
        render :new
      end
    end

    def destroy
      @market.delivery_schedules.soft_delete(params[:id])
      redirect_to [:admin, @market, :delivery_schedules], notice: "Deleted delivery schedule."
    end

    private

    def delivery_schedule_params
      params.require(:delivery_schedule).permit(
        :day,
        :buyer_day,
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
