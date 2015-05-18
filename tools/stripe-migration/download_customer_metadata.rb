require_relative "../../config/environment"

module DownloadCustomerMetadata
  class << self
    def go(file:)
      data = get_all
      File.open(file,"w") do |f| f.print YAML.dump(data) end
      puts "(wrote #{file}, #{data.count} customers)"
    end

    def get_all
      all_customers = Util::StripeEnumerator.create(limit: 100) { |params| Stripe::Customer.all(params) }
      all_customers.map do |cust|
        cust_keys = %w{id description created livemode sources}.map(&:to_sym)
        x = cust.to_hash.slice(*cust_keys)
        x[:metadata] = cust.metadata.to_hash
        x[:sources] = cust.sources.map do |s|
          keys = %w{id last4 brand funding exp_year exp_month fingerprint country name}.map(&:to_sym)
          s.to_hash.slice(*keys)
        end

        x
      end
    end
  end
end

DownloadCustomerMetadata.go file: "tools/stripe-migration/downloaded_customers.yml"
