namespace :qb do
  task :renew do
    expiring_tokens = QbToken.where('token_expires_at < ?', 30.days.from_now)

    expiring_tokens.each do |record|
      access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, record.access_token, record.access_secret)
      service = Quickbooks::Service::AccessToken.new
      service.access_token = access_token
      service.company_id = record.company_id
      new_token = service.renew

      case new_token.error_code
        when "0" # Success
          # Update the stored values
          record.update_attributes!(
              access_token: new_token.token,
              access_secret: new_token.secret,
              token_expires_at: 180.days.from_now.utc,
          )
          puts "Renewal succeeded"
        when "270" # The OAuth access token has expired.
          # Discard any saved credentials, need to restart the OAuth process
          record.update_attributes!(
              access_token: nil,
              access_secret: nil,
              token_expires_at: nil,
          )
          puts "Renewal failed"
        when "212" # Token Refresh Window Out of Bounds
          # Tried to renew it more than 30 days before expiration
          puts "Renewal ignored, tried too soon"
        else
          puts "Renewal failed, code: #{new_token.error_code} message: #{new_token.error_message}"
      end
    end
  end
end