class Regexp
  def schema_walk(value, mapper)
    value = value.to_str if value.respond_to?(:to_str)
    if value.is_a?(String) && value =~ self
      return value
    else
      return RSchema::ErrorDetails.new("is not a String matching #{self.inspect}")
    end
  end
end
