# Prepackaged validation to ensure all passed data is in the canonical format.

class ProductImport::Transforms::ValidateCanonicalData < ProductImport::Framework::TransformPipeline

  transform :validate_keys_are_present,
    keys: %w(product_code name category price unit)

  transform :validate_against_schema,
    schema: ProductImport::Schemas::CANONICAL

end
