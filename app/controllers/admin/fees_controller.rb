module Admin
  class FeesController < AdminController
    #before_action :require_admin
    before_action :lookup_market

    def show
      @seller_cc_rate = ::Financials::Pricing.seller_cc_rate(current_market)
    end

    def update
      market_attrs = fee_params.except(:plan_id, :plan_start_at, :plan_interval, :plan_fee, :plan_bank_account_id)
      org_attrs = fee_params.slice(:plan_id, :plan_start_at, :plan_interval, :plan_fee, :plan_bank_account_id)
      payment_fees_paid_by = market_attrs.delete('payment_fees_paid_by')
      @market.set_credit_card_payment_fee_payer(payment_fees_paid_by)

      if @market.update_attributes(market_attrs) && @organization.update_attributes(org_attrs)

        if @market.organization.plan.name == 'Solo Seller'
          organization_params = {
              :name => @market.name,
              :can_sell => true,
              :org_type => 'S',
              :active => true,
              :allow_credit_cards => @market.allow_credit_cards,
              :allow_purchase_orders => @market.allow_purchase_orders
          }
          result = CreateOrganization.perform(organization_params: organization_params, user: current_user, market_id: @market.id)
          puts result
        end

        redirect_to [:admin, @market, :fees], notice: "#{@market.name} fees successfully updated"
      else
        render :show
      end
    end

    protected

    def lookup_market
      @market = current_user.markets.find(params[:market_id]).decorate
      @organization = @market.organization
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
        :payment_fees_paid_by,
      ])
    end
  end
end
