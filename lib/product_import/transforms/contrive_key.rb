
class ProductImport::Transforms::ContriveKey < ProductImport::Framework::Transform
  def transform_step(row)
    if opts[:skip_if_present] && row['contrived_key']
      continue row
      return
    end

    parts = row.values_at(*opts[:from])

    if parts.any?(&:blank?)
      reject "Couldn't contrive a key, some fields are blank."
    else
      row['contrived_key'] = ExternalProduct.contrive_key(parts)
      continue row
    end

  end
end
