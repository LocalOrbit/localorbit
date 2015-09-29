require 'dragonfly'
require 'dragonfly/s3_data_store'

Dragonfly.app.configure do
  plugin :imagemagick

  protect_from_dos_attacks true
  secret "c8583e781acd7fdbb14323520b44d98d1b29c345cfcbcb0003078a6bc4da670b"

  url_host   Figaro.env.dragonfly_host
  url_format "/media/:job/:name"

  s3_headers = {
    "x-amz-acl"     => "public-read",
    "Cache-Control" => 'max-age=315576000, public',
  }
  s3_headers['x-amz-storage-class'] = 'REDUCED_REDUNDANCY' unless Rails.env.production?

  if Rails.env.development?
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  else
    datastore :s3,
      bucket_name:       Figaro.env.uploads_bucket,
      access_key_id:     Figaro.env.uploads_access_key_id,
      secret_access_key: Figaro.env.uploads_secret_access_key,
      region:            Figaro.env.uploads_region,
      url_scheme:        "https",
      url_host:          Figaro.env.uploads_host,
      headers:           s3_headers
  end

  Fog.mock! if Rails.env.test?
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
