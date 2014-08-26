namespace :import do
  desc "imports legacy taxonomy categories from a CSV given by FILE"
  task taxonomy: [:environment] do
    taxonomy_file = ENV["FILE"]
    raise "import:taxonomy requires a valid CSV" if taxonomy_file.nil?
    ImportLegacyTaxonomy.run(taxonomy_file, verbose: true)
  end

  desc "imports legacy units from a CSV given by FILE"
  task units: [:environment] do
    file = ENV["FILE"]
    raise "import:units requires a valid CSV" if file.nil?
    ImportLegacyUnits.run(file, verbose: true)
  end
end
