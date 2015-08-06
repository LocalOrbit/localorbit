# ALl of the below is made up and potentially quite wrong.  Assume each of the
# following is a rough sketch and is probably incomplete and/or not up to date
# with how things should be structured.
#
# When you go to build one of these, you're probably better off doing a
# rails g product_import:file_importer and porting over relevant bits.

module Import

  class Barons < Framework::FileImporter

    format :xls

    stage :extract do
      s.transform :from_table_grouped_by_category,
        category_column: 0,
        heading_columns: ["Item", "Item #", "Package Size", "Price/#", "Price/cs.", "QTY.", "Container"],

      s.transform :validate_keys_are_present, 
        keys: ["Item", "Item #", "Package Size", "Price/cs."]
    end

    stage :canonicalize do |s|
      s.transform :translate_keys, map: {
        "Item #" => "product_code",
        "Item" => "name",
        "Package Size" => "unit",
        "Price/cs." => "price"
      }

  #     transform :join_keys,
  #       into: "name",
  #       keys: %w(brandname desc)

      s.transform :ensure_canonical_data
    end


  end


  class PacificGourmet < Framework::FileImporter

    format :xlsx

    stage :extract do |s|
      s.transform_format :from_flat_table,
        headers: true
    end
  
    stage :canonicalize do |s|
      s.transform :translate_keys, map: {
        "SKU" => "product_code",
        "PACK" => "unit",
        "ITEM CATEGORY" => "category"
      }

      # Convert unit "30/1lb" to a "unit_count" of 30
      s.transform :convert_uom_price,
        uom_key: "UOM",
        price_key: "UNIT PRICE",


      s.transform :join_keys,
        into: "name",
        keys: ["Brand", "Product Description"]

      s.transform :ensure_canonical_data
    end

  end

end











# class ChunkedEnum
#   def initialize(source, chunk_size)
#     @chunk_size = chunk_size
#     @buffer = Array.new(chunk_size)
#     @source = source
#   end
#
#   def each
#     i = 0
#
#     @source.each do |v|
#       @buffer[i] = v
#       i += 1
#
#       if i == @chunk_size
#         @buffer.each do |v|
#           yield v
#         end
#         i = 0
#       end
#
#     end
#
#     if i > 0
#       @buffer.slice!(i, @buffer.size - i)
#       @buffer.each do |v|
#         yield v
#       end
#     end
#   end
#
#   def current_chunk
#     @buffer
#   end
# end
