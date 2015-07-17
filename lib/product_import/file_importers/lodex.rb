module ProductImport
  module FileImporters
    class Lodex < Framework::FileImporter
      format :csv

      stage :extract do |s|
        s.transform :from_flat_table,
          headers: true,
          required_headers: %w(product_code name category price unit)
      end

      stage :canonicalize do |s|
        s.transform :ensure_canonical_data
      end
    end
  end
end

