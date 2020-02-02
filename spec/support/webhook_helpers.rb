module WebhookHelpers
  def post_webhook(event_type, endpoint = '/webhooks/stripe')
    payload = JSON.parse(File.read("spec/fixtures/stripe_webhooks/#{event_type}.json"))
    post endpoint, payload
  end
end

