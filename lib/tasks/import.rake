namespace :import do
  desc "imports legacy taxonomy categories from a CSV given by TAXONOMY_FILE"
  task taxonomy: [:environment] do
    taxonomy_file = ENV['TAXONOMY_FILE']
    raise "import:taxonomy requires a valid CSV" if taxonomy_file.nil?
    ImportLegacyTaxonomy.run(taxonomy_file, verbose: true)
  end
end
