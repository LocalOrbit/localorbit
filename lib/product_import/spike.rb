
module Import

  class Bakers < Importer

    validate

    format :xlsx
    process_format :remove_empty_rows
    process_format :from_table_grouped_by_category,
      category_column: 2,
      heading_columns: [nil, "CODE", "PRODUCTS", "Reorder Cycle", nil, "PRICE"],


#     validate 
#       keys: %w(item desc gname brandname)
#
#     transform :translate_keys, map: {
#       "item" => "product_code",
#       "desc" => "name",
#     }
#
#     transform :join_keys,
#       into: "name",
#       keys: %w(brandname desc)

    transform :lookup_or_create_category,
      map_file: "bakers_categories.yml"


  end

  class Barons < Importer

    format :xls
    process_format :from_table_grouped_by_category,
      category_column: 0,
      heading_columns: ["Item", "Item #", "Package Size", "Price/#", "Price/cs.", "QTY.", "Container"],
#
#     validate 
#       keys: %w(item desc gname brandname)
#
#     transform :translate_keys, map: {
#       "item" => "product_code",
#       "desc" => "name",
#     }
#
#     transform :join_keys,
#       into: "name",
#       keys: %w(brandname desc)

    transform :lookup_or_create_category,
      map_file: "barons_categories.yml"


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
