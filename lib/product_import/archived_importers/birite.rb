module ProductImport
  module FileImporters
    class Birite < Framework::FileImporter

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = ['Distributor Item#', 'Brand', 'Product Description', 'Category', 'Pack', 'Size', 'Priced by Pound', 'Weight', 'Price']

      # See lib/product_import/formats for supported formats
      format :csv

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
          keys: REQUIRED_HEADERS - ['Brand', 'Size'] # TODO need to change any for general product?

        s.transform :alias_keys, key_map: {
          "Distributor Item#" => "product_code",
          "Price" => "price", # TODO will need to alias another key as unit/description, figure out how to deal with the different-pack-sizes
        }

        s.transform :join_keys,
          into: "name",
          keys: ["Brand", "Product Description"]

        s.transform :join_keys,
          into: "unit",
          keys: ["Pack", "Size"],
          with: " / "

        s.transform :convert_priced_by_weight_items,
          flag_key: 'Priced by Pound',
          multiplier_key: 'Weight'

        s.transform :map_category,
          filename: "birite.csv",
          input_key: "Category"

        s.transform :ensure_canonical_data
      end
    end
  end
end

