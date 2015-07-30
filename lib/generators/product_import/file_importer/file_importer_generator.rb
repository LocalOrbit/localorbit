class ProductImport::FileImporterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  desc "This generator creates a file importer"
  def create_file_importer
    template "example.rb", "lib/product_import/file_importers/#{file_name}.rb"
    template "example_spec.rb", "spec/lib/product_import/file_importers/#{file_name}_spec.rb"
  end
end
