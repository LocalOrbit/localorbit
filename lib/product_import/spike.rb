
module Import

  class Bakers < FileImporter

    format :xlsx
    process_format :remove_empty_rows

    process_format :from_table_grouped_by_category,
      category_column: 2,
      heading_columns: [nil, "CODE", "PRODUCTS", "Reorder Cycle", nil, "PRICE"],
    # Assume that the output of this step is hashes. Keys are entries in heading_columns (if non-nil)
    # or column number (if nil). This last point to support getting values which don't have labels

    validate keys: ['CODE', 'PRODUCTS', 'Reorder Cycle', 'PRICE', 
      # Created by from_table_grouped_by_category
      "category"]

    transform :translate_keys, map: {
      "CODE" => "product_code",
      "PRODUCTS" => "name",

      #
      4 => "size",
      "PRICE" => 'price',
    }

    transform :lookup_or_create_category


  end

  class Barons < FileImporter

    format :xls
    process_format :remove_empty_rows

    process_format :from_table_grouped_by_category,
      category_column: 0,
      heading_columns: ["Item", "Item #", "Package Size", "Price/#", "Price/cs.", "QTY.", "Container"],
#
    validate 
      keys: ["Item", "Item #", "Package Size", "Price/cs."]
#
    transform :translate_keys, map: {
      "Item #" => "product_code",
      "Item" => "name",
      "Package Size" => "unit",
      "Price/cs." => "price"

    }
#
#     transform :join_keys,
#       into: "name",
#       keys: %w(brandname desc)

    transform :lookup_or_create_category


  end

  # CSV
  class BiRite < FileImporter

    format :csv

    transform_format :from_flat_table,
      headers: true
  
    # Question: Does distributor name need to be in here? Is Order Guide# important?
    transform :contrive_key, from: ["Order Guide#", "Distributor Item#"]

    transform :translate_keys, map: {
      "Distributor Item#" => "product_code",
      "Size" => "unit",
      "Price" => "price",
    }

    transform :join_keys,
      into: "name",
      keys: ["Brand", "Product Description"]

    transform :lookup_or_create_category

  end

  class ChefsWarehouse < FileImporter

    format :xlsx

    transform_format :from_flat_table,
      headers: true
  
    transform :translate_keys, map: {
      "ITEM" => "product_code",
      "PACK" => "unit",
      "CLASS -SUBCLASS" => "category"
    }

    transform :convert_uom_price,
      uom_key: "UOM",
      price_key: "LASTPRICE"

    transform :join_keys,
      into: "name",
      keys: ["Brand", "Product Description"]

    transform :lookup_or_create_category

  end

  class PacificGourmet < FileImporter

    format :xlsx

    transform_format :from_flat_table,
      headers: true
  
    transform :translate_keys, map: {
      "SKU" => "product_code",
      "PACK" => "unit",
      "ITEM CATEGORY" => "category"
    }

    # Convert unit "30/1lb" to a "unit_count" of 30
    transform :convert_uom_price,
      uom_key: "UOM",
      price_key: "UNIT PRICE",


    transform :join_keys,
      into: "name",
      keys: ["Brand", "Product Description"]

    transform :lookup_or_create_category

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
