class ProductImport::Transforms::DumpCategory < ProductImport::Framework::Transform
  MISC_CATEGORY = "Miscellaneous"

  def initialize(opts={})
    super


    @seen_categories = Set.new
  end

  def file_path
    "lib/product_import/file_importers/category_mappings/#{opts[:filename]}"
  end

  def dump_category(cat, map_to)
    puts "dumping #{cat}"
    File.open(file_path, "a"){|io| io.puts [cat, map_to].to_csv }
  end

  def transform_step(row)
    category = row[opts[:input_key]]

    unless @dumped_header
      raise ArgumentError, "#{file_path} already exists" if File.exists?(file_path)
      dump_category "KEY", "CATEGORY"
      @dumped_header = true
    end

    unless @seen_categories.include? category
      dump_category category, MISC_CATEGORY
      @seen_categories << category
    end

    continue row
  end
end
