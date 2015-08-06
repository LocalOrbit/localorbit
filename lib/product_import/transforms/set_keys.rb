
class ProductImport::Transforms::SetKeys < ProductImport::Framework::Transform
  def transform_step(row)
    if opts[:skip_if_present]
      opts[:map].each do |key, value|
        if row[key].blank?
          row[key] = value
        end
      end
    else
      continue row.reverse_merge(opts[:map])
    end
  end
end
