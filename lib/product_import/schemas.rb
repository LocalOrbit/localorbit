module ProductImport::Schemas
  CANONICAL = RSchema.schema {{
    'product_code' => String,
    'name' => String,
    'category' => %r{^([a-z/0-9&_ -]*>)*[a-z/0-9&_ -]*$}i,
    'price' => /^(?:\d+\.)?\d+$/,
    'unit' => String,

    _?('short_description') => String,
    _?('long_description') => String,
    _?('source_data') => hash_of(String => either(String, Numeric)),
  }}

  RESOLVED_CANONICAL = RSchema.schema {{
    'organization_id' => Integer,
    'market_id' => Integer,
    'category_id' => Integer,

    'product_code' => String,
    'name' => String,
    'price' => /^(?:\d+\.)?\d+$/,
    'unit' => String,

    _?('short_description') => String,
    _?('long_description') => String,
    _?('source_data') => hash_of(String => either(String, Numeric)),
  }}
end
