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

  desc "imports products for Zynga marketplaces"
  task zynga_products: [:environment] do
    products_file = ENV["FILE"]
    raise "must specify FILE=path/to/products.csv" unless products_file
    require 'csv'
    data = open(products_file).read
    products = CSV.parse(data, headers: true)

    sellers = {
      "The Chef's Warehouse" => 4941,
      "Bi-Rite" => 4981
    }

    unit_id = Unit.where(singular: "Each").first.id

    products.each do |row|
      puts "Validating product #{row.inspect}"

      seller_name,
      product_name,
      category_name,
      price = row.values_at('Seller Name', 'name',
                            'category', 
                            'price')

      seller_id = sellers[seller_name]
      category_id = ProductImport::CategoryMap[category_name]

      raise "no Category ID (couldn't find #{category_name})" unless category_id
      raise "no Unit ID" unless unit_id
      raise "no Price" unless price
      raise "unknown Seller ID" unless seller_id
    end

    products.each do |row|
      seller_name, product_name,
      category_name,
      code,
      short_description,
      long_description,
      unit_description,
      price = row.values_at('Seller Name', 'name',
                            'category',
                            'product_code',
                            'Short Description',
                            'Long Description', 
                            'unit',
                            'price')

      category_id = ProductImport::CategoryMap[category_name]

      seller_id = sellers[seller_name]

      puts "Importing #{product_name} - #{short_description} - #{seller_name}"

      prod = Product.create!(
        name: product_name,
        organization_id: seller_id,
        unit_id: unit_id,
        category_id: category_id,
        code: code,
        short_description: short_description,
        long_description: long_description,
        unit_description: unit_description
      )

      prod.lots.create!(quantity: 999_999)
      prod.prices.create!(sale_price: price, min_quantity: 1)

    end
    puts "DONE!"
  end
end
