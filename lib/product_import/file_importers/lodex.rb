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
          required_keys: %w(product_code name category price unit)
      end

      stage :canonicalize do |s|
        # transform :translate_keys, map: {
        #   "item" => "product_code",
        #   "desc" => "name",
        #   "gname" => "category",
        # }

        # transform :join_keys,
        #   into: "name",
        #   keys: %w(brandname desc)

        # transform :lookup_or_create_category,
        #   column: "gname",
        #   map_file: "cooks_categories.yml"

        # s.transform :set_market_and_organization do |row|
        #   row['market_id'] = @market_id
        #   row['organization_id'] = @organization_id
        #   continue row
        # end
      end
    end
  end
end

