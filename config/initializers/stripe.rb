Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
Stripe.api_version = '2019-12-03'

StripeEvent.signing_secrets = [
  ENV.fetch('STRIPE_ACCOUNT_SIGNING_SECRET'),
  ENV.fetch('STRIPE_CONNECT_SIGNING_SECRET')
]

StripeEvent.configure do |events|
  events.all PaymentProvider::Handlers::AsyncHandler.new
end
