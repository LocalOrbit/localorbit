module Interactor
  def require_in_context(*names)
    context_keys = context.keys
    names.each do |name|
      if !context_keys.include?(name)
        raise "Interactor #{self.class.name} requires #{name.inspect} but it wasn't found in context."
      end
    end
    names.map do |name|
      self.send(name)
    end
  end
end
