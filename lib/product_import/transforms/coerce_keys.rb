
class ProductImport::Transforms::CoerceKeys < ProductImport::Framework::Transform
  def transform_step(row)
    opts[:map].each do |key, method|
      row[key] = row[key].send method
    end

    continue row

    # To flag this row as invalid
    #   reject "the reason this failed"
  end
end
