module ProductImport
  module FileImporters
    class Cooks < FileImporter

      format :xlsx

#       transform_format :remove_empty_rows
#       transform_format :from_flat_table,
#         header: true
#
#       validate :keys_are_present,
#         keys: %w(item desc gname brandname)

      transform :translate_keys, map: {
        "item" => "product_code",
        "desc" => "name",
      }

#       transform :join_keys,
#         into: "name",
#         keys: %w(brandname desc)
#
#       transform :lookup_or_create_category,
#         column: "gname",
#         map_file: "cooks_categories.yml"


    end
  end
end

