class ProductImport::Transforms::MapCategory < ProductImport::Framework::Transform
  def initialize(opts={})
    super
    if @mappings then return end
    file_text = File.read("lib/product_import/file_importers/category_mappings/#{opts[:filename]}")
    @mappings = {}
    CSV.parse(file_text, :headers => true).each do |row|
      row = row.to_hash
      @mappings[row['KEY']] = row['CATEGORY']
    end
  end

  def transform_step(row)
    input_category = row[opts[:input_key]]
    mapped_category = @mappings[input_category]
    if mapped_category
      row['category'] = mapped_category
      continue row
    else
      reject "Category #{input_category} not found in #{opts[:filename]}"
    end
  end
end
