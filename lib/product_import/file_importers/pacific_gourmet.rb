module ProductImport
  module FileImporters
    class PacificGourmet < Framework::FileImporter

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = ['SKU', 'DESCRIPTION', 'PACK', 'ITEM CATEGORY', 'BRAND', 'UNIT PRICE']

      # See lib/product_import/formats for supported formats
      format :xlsx

      # This stage is responsible for transforming raw data from
      # the format reader into basic sequence of hashes.
      #
      # Any rejection in this stage causes the entire file to
      # be rejected
      stage :extract do |s|

        s.transform :from_flat_table,
          headers: true,
          required_headers: REQUIRED_HEADERS

      end

      # This stage transforms the output of the extract stage
      # into the canonical format. Any rejected row is not imported
      # and saved for processing/triage.
      stage :canonicalize do |s|
        s.transform :join_keys,
          keys: ["BRAND", "DESCRIPTION"],
          with: " - ",
          into: "name"

        s.transform :dump_category,
          filename: "pacific_gourmet.csv",
          input_key: "ITEM CATEGORY"

        s.transform :alias_keys,
          key_map: {
            "SKU" => "product_code",
            "UNIT PRICE" => "price",
            "PACK" => "unit"
          }


        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data
      end
    end
  end
end

