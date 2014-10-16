module Interactor
  def require_in_context(*names)
    names.map do |name|
      if context[name]
        self.send(name)
      else
        raise "Interactor #{self.class.name} requires #{name.inspect} but it wasn't found in context."
      end
    end
  end
end
