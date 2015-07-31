
class ProductImport::Transforms::JoinKeys < ProductImport::Framework::Transform
  def transform_step(row)
    sources = row.values_at(*opts[:keys])
    with = opts.fetch(:with, ' ')
    row[opts[:into]] = sources.reject(&:blank?).join(with)
    continue row
  end
end
