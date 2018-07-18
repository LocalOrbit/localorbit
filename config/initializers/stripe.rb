Stripe.api_key = Figaro.env.stripe_secret_key
Stripe.api_version = '2019-12-03'

StripeEvent.signing_secrets = [
  Figaro.env.stripe_account_signing_secret,
  Figaro.env.stripe_connect_signing_secret
]

StripeEvent.configure do |events|
  events.all PaymentProvider::Handlers::AsyncHandler.new
end
