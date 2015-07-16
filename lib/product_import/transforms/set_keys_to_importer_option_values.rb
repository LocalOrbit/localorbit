class ProductImport::Transforms::SetKeysToImporterOptionValues < ProductImport::Framework::Transform
  def sets
    @sets ||= begin
                kvs = opts[:map].map do |set_key, get_key|
                  set_key = set_key.to_s if set_key.is_a? Symbol
                  value = importer.opts[get_key]
                  [set_key, value]
                end

                Hash[kvs]
              end
  end

  def transform_step(row)
    continue sets.merge(row)
  end
end
