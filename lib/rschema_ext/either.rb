module RSchema::DSL
  EitherSchema = Struct.new(:subschemas) do
    def schema_walk(value, mapper)
      errors = []
      subschemas.each do |subschema|
        value_walked, error = RSchema.walk(subschema, value, mapper)
        if error
          errors << error
        else
          return value_walked
        end
      end
      message = errors.map(&:details).join(", AND ")
      return RSchema::ErrorDetails.new(message)
    end
  end

  def self.either(*subschemas)
    EitherSchema.new(subschemas)
  end
end
