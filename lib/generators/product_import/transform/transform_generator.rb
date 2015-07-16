class ProductImport::TransformGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates a transform"
  def transform
    template "transform.rb", "lib/product_import/transforms/#{file_name}.rb"
    template "transform_spec.rb", "spec/lib/product_import/transforms/#{file_name}_spec.rb"
  end
end
