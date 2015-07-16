
class ProductImport::Transforms::<%= class_name %> < ProductImport::Framework::Transform
  def transform_step(row)
    # Use continue to pass the transformed data onto the next stage.
    continue row

    # To flag this row as invalid
    #   reject "the reason this failed"
  end
end
