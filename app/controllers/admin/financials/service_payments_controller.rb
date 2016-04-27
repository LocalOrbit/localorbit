class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment.map(&:decorate)
  end

  def create
    market = Market.find(params[:market_id])
    if market.stripe_customer_id?
      # Retrieve Stripe customer
      customer = PaymentProvider::Stripe.get_stripe_customer(market.stripe_customer_id)

      # Retrieve card (f card exists)
      customer.sources.data.each do |source|
        card = source if source.object = 'card'  
        break if source.object = 'card'  
      end

      # ...just create one
      stripe_subscription_data = {
        plan: market.plan.strip_id,
        source: card,
        metadata: {
          "lo.entity_id" => market.id,
          "lo.entity_type" => market.class.name.underscore
        }
      }
      
      # Stripe complains if you pass an empty coupon.  Only add it if it exists
      # stripe_subscription_data[:coupon] = subscription_params[:coupon] if !subscription_params[:coupon].blank?

      subscription = customer.subscriptions.create(stripe_subscription_data)

      # (along with the market and plan info) to ChargeServiceFee
    else 
      # Prompt that card needs to be created
    end
    charge = ChargeServiceFee.perform(market: market, amount: market.plan_fee, bank_account: market.plan_bank_account)
    if charge.success?
      redirect_to admin_financials_service_payments_path, notice: "Payment made for #{market.name}"
    else
      redirect_to admin_financials_service_payments_path, notice: "Payment failed for #{market.name}"
    end
  end
end
