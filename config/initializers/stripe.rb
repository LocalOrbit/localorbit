Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
Stripe.api_version = '2019-12-03'

StripeEvent.configure do |events|
  events.all PaymentProvider::Handlers::AsyncHandler.new
end

StripeEvent.event_filter = lambda do |params|
  if params[:type] == 'payout.paid' then
    managed_account_id = params[:user_id]
    # TODO: branch on presence of managed_account_id in case we're receiving a platform event,
    #        in which case retrieve without second arg
    # TODO: tack on event[:account_type] = :platform or something to indicate source of event
    event = Stripe::Event.retrieve(params[:id], {stripe_account: managed_account_id})
    event[:user_id] = managed_account_id
  else
    event = Stripe::Event.retrieve(params[:id])
  end
  event
end
