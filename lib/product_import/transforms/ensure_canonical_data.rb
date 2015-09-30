# Prepackaged validation to ensure all passed data is in the canonical format.

class ProductImport::Transforms::EnsureCanonicalData < ProductImport::Framework::TransformPipeline

  transform :validate_keys_are_present,
    keys: %w(organization name category price unit unit_description) # require category even though it may change in future, prod to upload must have one

  transform :contrive_key,
    from: %w(organization name unit unit_description), # don't need to validate product code now
    skip_if_present: true

  transform :move_non_canonical_fields_to_source_data

  transform :validate_against_schema,
    schema: ProductImport::Schemas::CANONICAL


end
