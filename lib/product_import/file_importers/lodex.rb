module ProductImport
  module FileImporters
    class Lodex < Framework::FileImporter

      format :csv

      stage :extract do |s|
        s.transform :from_flat_table,
          headers: true,
          required_keys: %w(product_code name category price unit)
      end

      stage :canonicalize do
        # transform :translate_keys, map: {
        #   "item" => "product_code",
        #   "desc" => "name",
        #   "gname" => "category",
        # }

        # transform :join_keys,
        #   into: "name",
        #   keys: %w(brandname desc)

        # transform :lookup_or_create_category,
        #   column: "gname",
        #   map_file: "cooks_categories.yml"

      end

    end
  end
end

