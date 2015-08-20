module ProductImport
  module FileImporters
    class Cooks < Framework::FileImporter
      REQUIRED_HEADERS = %w(item desc gname brandname master mstruom)

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
          # if any of these are missing, don't even try to process the file
          required_headers: REQUIRED_HEADERS

      end

      # This stage transforms the output of the extract stage
      # into the canonical format. Any rejected row is not imported
      # and saved for processing/triage.
      stage :canonicalize do |s|

        # Reject any rows which have blank required fields
        s.transform :validate_keys_are_present,
          keys: %w(item desc gname brandname)

        # TODO: Add your transforms here

        # provide default values and validate that we've generated
        # canonical data.
        s.transform :ensure_canonical_data
      end
    end
  end
end
