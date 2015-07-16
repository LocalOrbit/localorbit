module ProductImport::Schemas
  CANONICAL = RSchema.schema {{
    'product_code' => String,
    'name' => String,
    'category' => %r{^([a-z/0-9&_ -]*>)*[a-z/0-9&_ -]*$}i,
    'price' => /^(?:\d+\.)?\d+$/,
    'unit' => String,

    _?('short_description') => String,
    _?('long_description') => String,
    _?('source_data') => hash_of(String => maybe(either(String, Numeric))),
  }}

  # Everything in canonical pluss database ids for required fields
  RESOLVED_CANONICAL = CANONICAL.merge(
    'organization_id' => Integer,
    'market_id' => Integer,
    'category_id' => Integer,
  )
end
