module ProductImport
  module FileImporters
    class Lodex < Framework::FileImporter
      attr_accessor :market_id

      def initialize(opts={})
        super
        self.market_id = opts[:market_id]
      end

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

