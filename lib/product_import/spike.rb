# ALl of the below is made up and potentially quite wrong.  Assume each of the
# following is a rough sketch and is probably incomplete and/or not up to date
# with how things should be structured.
#
# When you go to build one of these, you're probably better off doing a
# rails g product_import:file_importer and porting over relevant bits.

module Import

  class Bakers < Framework::FileImporter

    format :xlsx

    stage :extract do |s|
      s.transform  :from_table_grouped_by_category,
        category_column: 2,
        heading_columns: [nil, "CODE", "PRODUCTS", "Reorder Cycle", nil, "PRICE"],
      # Assume that the output of this step is hashes. Keys are entries in heading_columns (if non-nil)
      # or column number (if nil). This last point to support getting values which don't have labels

      s.transform  validate_keys_are_present,
        keys: ['CODE', 'PRODUCTS', 'Reorder Cycle', 'PRICE', 
          # Created by from_table_grouped_by_category
          "category"]
    end

    stage :canonicalize do |s|
      s.transform :translate_keys, map: {
        "CODE" => "product_code",
        "PRODUCTS" => "name",

        4 => "size",
        "PRICE" => 'price',
      }

      s.transform :ensure_canonical_data
    end


  end

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

  # CSV
  class BiRite < Framework::FileImporter

    format :csv

    stage :extract do |s|
      s.transform :from_flat_table,
        headers: true
    end


    stage :canonicalize do |s|
      # Question: Does distributor name need to be in here? Is Order Guide# important?
      s.transform :contrive_key, from: ["Order Guide#", "Distributor Item#"]

      s.transform :translate_keys, map: {
        "Distributor Item#" => "product_code",
        "Size" => "unit",
        "Price" => "price",
      }

      s.transform :join_keys,
        into: "name",
        keys: ["Brand", "Product Description"]

      s.transform :join_keys,
        into: "name",
        keys: ["Pack", "Size"],
        join_with: " / "

      s.transform :ensure_canonical_data
    end

  end

  class ChefsWarehouse < Framework::FileImporter

    format :xlsx

    stage :extract do |s|
      s.transform :from_flat_table,
        headers: true
    end
  
    stage :canonicalize do |s|
      s.transform :translate_keys, map: {
        "ITEM" => "product_code",
        "PACK" => "unit",
        "CLASS -SUBCLASS" => "category"
      }

      s.transform :convert_uom_price,
        uom_key: "UOM",
        price_key: "LASTPRICE"

      s.transform :join_keys,
        into: "name",
        keys: ["Brand", "Product Description"]

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
