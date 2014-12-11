module SchemaValidationHelpers
  def expect_valid_schema(schema, value)
    SchemaValidation.with_validation(true) do
      SchemaValidation.validate!(schema, value)
    end
  end
end

RSpec.configure do |config|
  config.include SchemaValidationHelpers
end
