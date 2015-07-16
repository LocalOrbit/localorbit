module ProductImport
  module FileImporters
    class <%= class_name %> < Framework::FileImporter
      attr_accessor :market_id

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
          required_headers: %w(product_code name category price unit)

      end

      # This stage transforms the output of the extract stage
      # into the canonical format. Any rejected row is not imported
      # and saved for processing/triage.
      stage :canonicalize do |s|

        # TODO: Add your transforms here

        s.transform :validate_canonical_data
      end
    end
  end
end

