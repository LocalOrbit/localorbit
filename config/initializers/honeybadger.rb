Honeybadger.configure do |config|
  config.api_key = "a7df8d88"
  config.metrics = false
  config.environment_name = Figaro.env.deploy_env
end
