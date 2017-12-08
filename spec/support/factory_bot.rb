RSpec.configure do |config|
  factory_bot_results = {}

  config.before(:suite) do
    ActiveSupport::Notifications.subscribe("factory_bot.run_factory") do |name, start, finish, id, payload|
      factory_name = payload[:name]
      strategy_name = payload[:strategy]
      factory_bot_results[factory_name] ||= {}
      factory_bot_results[factory_name][strategy_name] ||= 0
      factory_bot_results[factory_name][strategy_name] += 1
    end
  end

  config.after(:suite) do
    puts "\n"
    puts '+' * 72
    puts 'Factory Bot usage ...'
    puts factory_bot_results
    puts '+' * 72
  end

end
