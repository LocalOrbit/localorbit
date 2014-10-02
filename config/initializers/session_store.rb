# Be sure to restart your server when you modify this file.

# Copy memcached cloud variables to memcache for easier config
ENV["MEMCACHE_SERVERS"]  = ENV["MEMCACHEDCLOUD_SERVERS"]  if ENV["MEMCACHEDCLOUD_SERVERS"]
ENV["MEMCACHE_USERNAME"] = ENV["MEMCACHEDCLOUD_USERNAME"] if ENV["MEMCACHEDCLOUD_USERNAME"]
ENV["MEMCACHE_PASSWORD"] = ENV["MEMCACHEDCLOUD_PASSWORD"] if ENV["MEMCACHEDCLOUD_PASSWORD"]

# Using memcache store because setting memcache as the cache store
# would not work unless we go with a large memcache plan
session_suffix = Figaro.env.deploy_env == 'production' ? '' : "_#{Figaro.env.deploy_env}"
session_key = "_local_orbit_session#{session_suffix}"
if Rails.env.production?
  Rails.application.config.session_store :mem_cache_store,
    memcache_server: (ENV["MEMCACHE_SERVERS"] || 'localhost:11211'),
    key: session_key,
    domain: ".#{Figaro.env.domain}"
else
  Rails.application.config.session_store :mem_cache_store,
  memcache_server: (ENV["MEMCACHE_SERVERS"] || 'localhost:11211'),
    key: session_key,
    domain: Rails.env.test? ? nil : ".#{Figaro.env.domain}"
end
