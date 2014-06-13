BigDecimal.class_eval do
  alias_method :old_inspect, :inspect

  def inspect
    old_inspect.sub(/'.*'/, "'#{to_s}'")
  end
end
