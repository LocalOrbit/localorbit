
class ProductImport::Transforms::ContriveKey < ProductImport::Framework::Transform
  def transform_step(row)
    unless opts[:skip_if_present] && row['contrived_key']
      row['contrived_key'] = ExternalProduct.contrive_key(row.values_at(*opts[:from]))
    end

    continue row

    # To flag this row as invalid
    #   reject "the reason this failed"
  end
end
