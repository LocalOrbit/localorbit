
class ProductImport::Transforms::MoveNonCanonicalFieldsToSourceData < ProductImport::Framework::Transform

  def canonical_field_keys
    @canonical_field_keys ||= begin
        keys = ProductImport::Schemas::CANONICAL.keys

        # Extract the keys from optional values
        keys.
          map {|k| k.respond_to?(:key) ? k.key : k }
      end
  end

  def transform_step(row)
    if row.keys.any?{|k| !canonical_field_keys.include?(k)}
      canon = row.slice(*canonical_field_keys)

      noncanon_keys = row.keys - canonical_field_keys
      noncanon = row.slice(*noncanon_keys)

      canon["source_data"] = noncanon.merge(canon['source_data'] || {})
      continue canon

    else
      continue row
    end
  end

end
