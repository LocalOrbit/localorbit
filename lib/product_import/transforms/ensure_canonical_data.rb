# Prepackaged validation to ensure all passed data is in the canonical format.

class ProductImport::Transforms::EnsureCanonicalData < ProductImport::Framework::TransformPipeline

  transform :validate_keys_are_present,
    keys: %w(product_code organization name category price unit)

  transform :contrive_key,
    from: %w(product_code organization name unit),
    skip_if_present: true

  transform :move_non_canonical_fields_to_source_data

  transform :validate_against_schema,
    schema: ProductImport::Schemas::CANONICAL


end
