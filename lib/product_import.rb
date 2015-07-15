module InstantiatableByName
  def lookup_class(name)
    klass_name = name.to_s.classify
    const_get(klass_name)
  end

  def instantiate(name, *args)
    lookup_class(name).new(*args)
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
