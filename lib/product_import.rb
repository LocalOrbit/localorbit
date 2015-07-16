module InstantiatableByName
  def lookup_class(name)
    klass_name = name.to_s.camelize
    const_get(klass_name)
  end

  # Build a standard "spec" - hash structure representing how
  # to instantiate an instance
  def build_spec(name, *args)
    {
      name: name,
      class: lookup_class(name),
      initialize_args: args
    }
  end

  # Build an instance given a spec
  def instantiate_spec(spec)
    spec[:class].new(*spec[:initialize_args])
  end
end

module ProductImport
  module Transforms
    extend InstantiatableByName
  end

  module Formats
    extend InstantiatableByName
  end

  module FileImporters
    extend InstantiatableByName
  end
end
