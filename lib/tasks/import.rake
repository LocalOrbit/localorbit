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

  desc "imports products for New Mexico marketplaces"
  task nm_products: [:environment] do
    products_file = ENV["FILE"]
    raise "must specifcy FILE=path/to/products.csv" unless products_file
    require 'csv'
    require 'open-uri'
    data = open('https://gist.githubusercontent.com/micahalles/996cf9bda40bf3f22c9e/raw/b0526291f79aee768b75f91e394411454148f211/products.csv').read
    products = CSV.parse(data, headers: true)

    Product.transaction do
      markets = {
        'Price: Farm to Restaurant' => 76,
        'Price: Farmers Market' => 80,
        'Price: NM Admin Site' => 84
      }
      sellers = {
        "Farm to Restaurant" => 3266,
        "Charybda Farms" => 3320,
        "Diamond Sow Gardens" => 3321,
        "Espanola Valley Farms" => 3322,
        "Box Car Organic Farm" => 3319,
        "Ancient Waters Farm" => 3317,
        "Bohdi Farms" => 3318,
        "Green Tractor Organic Farm" => 3323,
        "La Mesa Organic Farm" => 3324,
        "Mendez Produce" => 3325,
        "MiYoung's Farm" => 3326,
        "Monte Vista Organic Farms" => 3327,
        "Mr. G's Organic Farm" => 3328,
        "Pojoaque Pueblo Farms" => 3329,
        "Rancho La Jolla" => 3330,
        "Red Mountain Farm" => 3331,
        "Santa Cruz Farms" => 3332,
        "Serrano Family Farm" => 3333,
        "Sungreen Living Foods" => 3334,
        "Wagner Farms" => 3335
      }
      products.each do |row|
        puts "Importing product #{row.inspect}"
        seller_name, product_name, category_id, short_description,
          long_description, unit_id, unit_description = row.values_at('Seller Name', 'Product Name',
          'Category ID', 'Short Description', 'Long Description', 'Unit ID', 'Unit Description (optional)',)
        raise "no Category ID" unless category_id
        raise "no Unit ID" unless unit_id
        seller_id = sellers[seller_name]
        prod = Product.create!(name: product_name, organization_id: seller_id,
          unit_id: unit_id, category_id: category_id, short_description: short_description,
          long_description: long_description, unit_description: unit_description)

        markets.each do |(price_header, market_id)|
          price = row[price_header]
          next if price == '#N/A'
          sale_price = price.gsub('$','')
          puts "  importing price #{sale_price} for market"
          prod.prices.create!(market_id: market_id, sale_price: sale_price, min_quantity: 1)
        end
      end
      puts "DONE!"
    end
  end

  desc "imports products for Zynga marketplaces"
  task zynga_products: [:environment] do
    products_file = ENV["FILE"]
    raise "must specify FILE=path/to/products.csv" unless products_file
    require 'csv'
    require 'product_import/categories.rb'
    data = open(products_file).read
    products = CSV.parse(data, headers: true)

    Product.transaction do
      sellers = {
        "The Chef's Warehouse" => 4941
      }

      products.each do |row|
        puts "Validating product #{row.inspect}"

        seller_name,
        product_name,
        category_name,
        category_id,
        unit_id,
        price = row.values_at('Seller Name', 'Product Name',
                              'Category Name', 'Category ID',
                              'Unit ID', 'Price')

        seller_id = sellers[seller_name]
        category_id = PREDEFINED_CATEGORY[category_name]

        raise "no Category ID" unless category_id
        raise "no Unit ID" unless unit_id
        raise "no Price" unless price
        raise "unknown Seller ID" unless seller_id
      end

      products.each do |row|
        seller_name, product_name,
        category_name, category_id,
        code,
        short_description,
        long_description, unit_id,
        unit_description,
        price = row.values_at('Seller Name', 'Product Name',
                              'Category Name', 'Category ID',
                              'Supplier Product Number',
                              'Short Description',
                              'Long Description', 'Unit ID',
                              'Unit Description (optional)',
                              'Price')

        category_id = PREDEFINED_CATEGORY[category_name]

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
end
