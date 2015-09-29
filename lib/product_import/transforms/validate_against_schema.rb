# Validates every row matches the provided schema. Rejects any which fail.
class ProductImport::Transforms::ValidateAgainstSchema < ProductImport::Framework::Transform
  def transform_step(row)
    begin
      RSchema.validate!(opts[:schema], row)
      continue row
      # poss: here validate and copy
    rescue => e
      reject "Failed schema validation (#{e.message})"
    end
  end
end
