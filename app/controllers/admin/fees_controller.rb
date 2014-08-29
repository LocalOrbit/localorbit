module Admin
  class FeesController < AdminController
    before_action :require_admin
    before_action :lookup_market

    def show
    end

    def update
      if @market.update_attributes(fee_params)
        redirect_to [:admin, @market, :fees], notice: "#{@market.name} fees successfully updated"
      else
        render :show
      end
    end

    protected

    def lookup_market
      @market = current_user.markets.find(params[:market_id])
    end

    def fee_params
      params.require(:market).permit([
        :local_orbit_seller_fee, :local_orbit_market_fee,
        :credit_card_seller_fee, :credit_card_market_fee,
        :ach_seller_fee, :ach_market_fee, :ach_fee_cap,
        :market_seller_fee,
        :po_payment_term,
        :plan_id,
        :plan_start_at,
        :plan_interval,
        :plan_fee,
        :plan_bank_account_id,
      ])
    end
  end
end
