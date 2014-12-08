class SchemaValidation
  cattr_accessor :validation
  self.validation = true

  def self.validate!(schema, object)
    if SchemaValidation.validation
      return RSchema.validate!(schema,object)
    else
      return object
    end
  end

  def self.with_validation(on_off)
    prior = self.validation 
    self.validation = on_off
    begin
      yield
    ensure
      self.validation = prior
    end
  end
end
