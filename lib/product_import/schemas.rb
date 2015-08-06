

module ProductImport::Schemas


  CANONICAL = RSchema.schema {{
    'product_code' => either(Integer,String),
    'name' => String,

    'category' => %r{^([a-z,/0-9&_ -]*>)*[a-z,/0-9&_ -]*$}i,
    # e.g. Grandparent > Parent > Brothers & Sisters

    'price' => either(Numeric, /^(?:\d+\.)?\d+$/),
    'contrived_key' => String,
    # e.g. 12.34

    'unit' => either(Integer,String),
    _?('uom') => String,

    _?('unit_description') => maybe(String),
    _?('short_description') => String,
    _?('long_description') => String,
    _?('organization') => String,
    _?('source_data') => Hash,
  }}


  # Everything in canonical pluss database ids for required fields
  RESOLVED_CANONICAL = CANONICAL.merge(
    'organization_id' => Integer,
    'market_id' => Integer,
    'category_id' => Integer,
  )
end



