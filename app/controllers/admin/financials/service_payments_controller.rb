class Admin::Financials::ServicePaymentsController < AdminController
  before_action :require_admin

  def index
    @markets = Market.active.sort_service_payment.map(&:decorate)
  end

  def create
    # Retrieve the market
    market   = Market.find(params[:market_id])

    # If the market is a Stripe customer...
    if customer = market.stripe_customer
      # ...then build the subscription hash...
      stripe_subscription_data = {
        plan: market.plan.stripe_id,
        metadata: {
          "lo.entity_id" => market.id,
          "lo.entity_type" => market.class.name.underscore
        }
      }
      
      # This is disabled for now...
      # Stripe complains if you pass an empty coupon.  Only add it if it exists
      # stripe_subscription_data[:coupon] = subscription_params[:coupon] if !subscription_params[:coupon].blank?

      # ...and create the subscription
      subscription = customer.subscriptions.create(stripe_subscription_data)

      # Capture the charge stripe id (for use later)
      invoices = PaymentProvider::Stripe.get_stripe_invoices(:customer => subscription.customer)
      invoice = invoices.data.first

    else
      # If the market is NOT a Stripe customer then alert accordingly
      redirect_to admin_financials_service_payments_path, notice: "#{market.name} is not yet a Stripe customer"

    end

    if subscription.nil?
      redirect_to admin_financials_service_payments_path, notice: "Failed to create subscription for #{market.name}"

    else
      market.subscribe!

      #binding.pry
      amount = ::Financials::MoneyHelpers.cents_to_amount(subscription.plan.amount)
      # KXM market.bank_accounts.first is clumsy and bad.  Fix it
      payment = CreateServicePayment.perform(market: market, amount: amount, bank_account: market.bank_accounts.first, invoice: invoice)
      if payment.success?
        redirect_to admin_financials_service_payments_path, notice: "Subscription to #{market.plan.name} created for #{market.name}"
      else
        redirect_to admin_financials_service_payments_path, notice: "Failed to create payment record for new subscription for #{market.name}"
      end
    end
  end
end
