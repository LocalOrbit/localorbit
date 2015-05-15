
Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

StripeEvent.configure do |events|
  events.all PaymentProvider::Handlers::AsyncHandler.new
end

StripeEvent.event_retriever = lambda do |params|
  managed_account_id = params[:user_id]
  # TODO: branch on presence of managed_account_id in case we're receiving a platform event, in which case retrieve without second arg
  # TODO: tack on event[:account_type] = :platform or something to indicate source of event
  event = Stripe::Event.retrieve(params[:id], {stripe_account: managed_account_id})
  event[:user_id] = managed_account_id
  event
end
