
class ProductImport::Transforms::SetKeys < ProductImport::Framework::Transform
  def transform_step(row)
    continue row.reverse_merge(opts[:map])
  end
end
