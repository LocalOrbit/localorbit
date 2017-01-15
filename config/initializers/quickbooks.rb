OAUTH_CONSUMER_KEY = ENV['QB_CONSUMER_KEY']
OAUTH_CONSUMER_SECRET = ENV['QB_CONSUMER_SECRET']

::QB_OAUTH_CONSUMER = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})

if Rails.env.test? || Rails.env.development?
  Quickbooks.sandbox_mode = true
else
  Quickbooks.sandbox_mode = false
end