# Requires that keys are present
class ProductImport::Transforms::ValidateKeysArePresent < ProductImport::Framework::Transform
  def transform_step(row)
    if opts[:keys].any?{|k| row[k].blank?}
      missing = opts[:keys].select{|k| row[k].blank?}
      reject "Missing required key(s): #{missing.join(", ")}"
    else
      continue row
    end
  end
end
