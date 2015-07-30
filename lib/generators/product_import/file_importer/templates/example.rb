module ProductImport
  module FileImporters
    class <%= class_name %> < Framework::FileImporter

      # if any of these are missing, don't even try to process the file
      REQUIRED_HEADERS = %w(foo bar baz)

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
          keys: %w(more headers or just REQUIRED_HEADERS)

        # TODO: Add your transforms here

        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data
      end
    end
  end
end

