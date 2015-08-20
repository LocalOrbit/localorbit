module ProductImport
  module FileImporters
    class BakersOfParis < Framework::FileImporter

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = %w(CODE PRODUCTS PRICE)

      # See lib/product_import/formats for supported formats
      format :xlsx

      # This stage is responsible for transforming raw data from
      # the format reader into basic sequence of hashes.
      #
      # Any rejection in this stage causes the entire file to
      # be rejected
      stage :extract do |s|

        s.transform  :from_table_grouped_by_category,
          category_column: 2,
          header_row_pattern: [nil, "CODE", "PRODUCTS", nil, nil, "PRICE"],
          required_headers: REQUIRED_HEADERS

      end

      # This stage transforms the output of the extract stage
      # into the canonical format. Any rejected row is not imported
      # and saved for processing/triage.
      stage :canonicalize do |s|

        # Reject any rows which have blank required fields
        s.transform :validate_keys_are_present,
          keys: REQUIRED_HEADERS

        s.transform :alias_keys, key_map: {
          "CODE" => "product_code",
          "PRODUCTS" => "name",
          "PRICE" => 'price',
        }

        s.transform :set_keys, map: {
          "unit" => "Each"
        }

        s.transform :map_category,
          filename: "bakers_specialty_foods.csv",
          input_key: "category"

        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data
      end
    end
  end
end

