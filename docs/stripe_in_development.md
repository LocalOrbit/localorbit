# Setting up Stripe on your local development environment

1. Sign up at stripe.com
1. Click the 'Viewing test data' slider to on in the sidebar
1. Go to the API link in the side bar
1. Copy the `Publishable key` into your application.yml as `STRIPE_PUBLISHABLE_KEY`
1. Copy the `Secret key` into your applicaiton .yml as `STRIPE_SECRET_KEY`

## To get your local market setup via the OAuth flow

1. On your local env, log in as the market manager `mm@example.com`
1. Go to Market Admin > Markets > 'Fulton Market' > Stripe
1. Click 'Connect with Stripe' button
1. On the page that shows how a user would sign up, instead click the link in the caution strip at the top of the page that says "Skip this account form"
1. Copy the instructions that look like this, and substitute your `STRIPE_SECRET_KEY`, and run it on the command line:


    curl -X POST https://connect.stripe.com/oauth/token \
    -d client_secret=YOUR_SECRET_KEY \
    -d code=ac_BwwUXshB03k9hxk3J9mf9ZV9sbjtPEVj \
    -d grant_type=authorization_code

1. Your response will look some lie

    {
      "access_token": "sk_test_n6m3slSJEOhFJK5Vk7mOum2T",
      "livemode": false,
      "refresh_token": "rt_BwwjfUUxrqTq33hRCoSbEMpt2UadtIKAaS3G4SZbpPKuY6j3",
      "token_type": "bearer",
      "stripe_publishable_key": "pk_test_JGvIa3qWQtEsT8rpY6DveIqO",
      "stripe_user_id": "acct_1BZ2OwXeDDexvDWm",
      "scope": "read_write"
    }

1. Copy the `stripe_user_id` value (`acct_1BZ2OwXeDDexvDWm`) and use it for your `STRIPE_DEV_MARKET_ACCOUNT_ID` in your application.yml.
1. Run `rake reset` to drop your dev db, recreate with new seed data. If it doesn't work, you may needs to stop all process running under spring (guard, rails console, etc.), and do `spring stop`, and try again.
1. You should be able to login as a buyer and interact with a working Market.

