RSpec.configure do |config|
 config.before(:suite) do
    # Turn off auditing on all tests, it does nothing but
    # slow us down
    # First load all the models
    Dir[Rails.root.join("app/models/**/*.rb")].each {|f| require f}

    Audit.audited_class_names.each do |audited_class|
      audited_class.constantize.disable_auditing
    end
  end
end
