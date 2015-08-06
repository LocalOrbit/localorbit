
class ProductImport::Transforms::ConvertPricedByWeightItems < ProductImport::Framework::Transform

  def transform_step(row)
    # Use continue to pass the transformed data onto the next stage.

    flag_key = opts[:flag_key]
    multiplier_key = opts[:multiplier_key]

    if row[flag_key].downcase == 'y'
      multiplier = row[multiplier_key]
      if multiplier.blank?
        reject "Missing multiplier for price by weight item"
      else
        multiply_price row, by: multiplier.to_f
        continue row
      end
    else
      multiply_price row, by: 1
      continue row
    end
  end

  def multiply_price(row, by:)
    row['original_price'] = row['price']
    row['price'] = "%.2f" % [row['price'].to_f * by]
  end

end
