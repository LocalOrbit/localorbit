Stripe.api_key = Figaro.env.stripe_secret_key
Stripe.api_version = '2015-04-07'

StripeEvent.signing_secret = Figaro.env.stripe_signing_secret
StripeEvent.configure do |events|
  events.all PaymentProvider::Handlers::AsyncHandler.new
end

StripeEvent.event_retriever = lambda do |params|
  if params[:type] == 'transfer.paid' then
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
