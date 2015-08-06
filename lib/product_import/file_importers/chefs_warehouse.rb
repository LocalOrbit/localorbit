module ProductImport
  module FileImporters
    class ChefsWarehouse < Framework::FileImporter

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = ['CLASS -SUBCLASS', 'ITEM', 'DESCRIPTION', 'PACK', 'UOM','LASTPRICE']

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

        # Reject any rows which have blank required fields
        s.transform :validate_keys_are_present,
          keys: REQUIRED_HEADERS

        # TODO: Add your transforms here
        s.transform :alias_keys, key_map: {
          "ITEM" => "product_code",
          "PACK" => "unit",
          'LASTPRICE' => 'price',
          "UOM" => 'uom',
          "CLASS -SUBCLASS" => "category",
          'DESCRIPTION' => 'name',
        }


        s.transform :convert_unit_of_measure

        s.transform :map_category,
          filename: "chefs_warehouse.csv",
          input_key: "category"

        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data
      end
    end
  end
end
