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

RSpec::Matchers.define :be_compliant_with_schema do |schema|
  match do |actual|
    SchemaValidation.with_validation(true) do
      SchemaValidation.validate!(schema, actual)
    end
  end
end

RSpec::Matchers.define :be_array_compliant_with_schema do |schema|
  match do |actual|
    actual = [actual] unless actual.is_a?(Array)

    actual.each do |v|
      SchemaValidation.with_validation(true) do
        SchemaValidation.validate!(schema, v)
      end
    end
  end
end
