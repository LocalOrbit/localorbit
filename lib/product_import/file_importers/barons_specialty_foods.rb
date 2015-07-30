module ProductImport
  module FileImporters
    class BaronsSpecialtyFoods < Framework::FileImporter

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = ["Item", "Item #", "Price/cs."]

      # See lib/product_import/formats for supported formats
      format :xls

      # This stage is responsible for transforming raw data from
      # the format reader into basic sequence of hashes.
      #
      # Any rejection in this stage causes the entire file to
      # be rejected
      stage :extract do |s|

        s.transform :from_table_grouped_by_category,
          category_column: 0,
          header_row_pattern: ["Item", "Item #", "Package Size", /Price/, "Price/cs.", nil, nil],
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
          "Item #" => "product_code",
          "Item" => "name",
          "Package Size" => "unit",
          "Price/cs." => "price"
        }

        s.transform :map_category,
          filename: "barons_specialty_foods.csv",
          input_key: "category"


        # TODO: Add your transforms here

        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data
      end
    end
  end
end

